
# behavioral analysis reaction times

library(readr)
library(lme4)
library(lmerTest)
library(ggplot2)
source("Y:/Personal/Peter/R_scripts/boot_glmm.r")
library(kyotil)
library(emmeans)

RTdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/behavioral_data/current_dat_file.csv")
RTdata$subj = factor(RTdata$subj)
RTdata$effector = factor(RTdata$effector)
RTdata$choice = factor(RTdata$choice)
RTdata$target_selected = factor(RTdata$target_selected)
RTdata$delay = factor(RTdata$delay)


Alldata = RTdata

# clean data
RTdata <- RTdata[RTdata$success == 1,]
RTdata <- RTdata[!(RTdata$RT == -99),]
RTdata <- RTdata[!(RTdata$RT > 0.8) ,]
RTdata <- RTdata[(RTdata$RT >= 0.2) ,]

RTdata$z.num_delay=as.vector(scale(RTdata$num_delay)) # z-transformation

RTdata$log_RT <- log(RTdata$RT)
# histogram

g_mRT <- ggplot(RTdata, aes(x = RT))
g_mRT + geom_histogram(bins = 100, fill = "white", color = "black")



######################### generalized lme
# gamma
gRTga <- glmer(RT ~ effector*choice*target_selected*z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
             family = Gamma(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

# inv.gaussian
gRTig <- glmer(RT ~ effector*choice*target_selected*z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
               family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))



source("Y:/Personal/Peter/R_scripts/overdisp_test.r")
disp.par(gRTga) # größer 1 ist antikonservativ
disp.par(gRTig) # 


# gamma
qqnorm(residuals(gRTga));qqline(residuals(gRTga))
hist(residuals(gRTga))
hist(RTdata$RT)

plot(residuals(gRTga), fitted(gRTga),pch=19, col=grey(level=0.7, alpha=0.2))
summary(gRTga)$varcor

# inverse gaussian
qqnorm(residuals(gRTig));qqline(residuals(gRTig))
hist(residuals(gRTig))
hist(RTdata$RT)

plot(residuals(gRTig), fitted(gRTig),pch=19, col=grey(level=0.7, alpha=0.2))
summary(gRTig)$varcor



################### linear mixed effect model INCL delay as fixed

mRT  <- lmer(RT ~ effector*target_selected * choice * num_delay + (1|subj), data = RTdata, REML = FALSE)
mRT2 <- lmer(RT ~ effector*target_selected * choice*z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), 
             data = RTdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))




qqnorm(residuals(mRT2));qqline(residuals(mRT2))
hist(residuals(mRT2))
hist(RTdata$RT)

plot(residuals(mRT2), fitted(mRT2),pch=19, col=grey(level=0.7, alpha=0.2))
summary(mRT2)$varcor

nrow(as.data.frame(summary(mRT2)$varcor))
length(fixef(mRT2))
length(residuals(mRT2))

#RTdata$effector.code       =as.numeric(RTdata$effector==levels(RTdata$effector)[2])
#RTdata$target_selected.code=as.numeric(RTdata$target_selected==levels(RTdata$target_selected)[2])
#RTdata$choice.code         =as.numeric(RTdata$choice==levels(RTdata$choice)[2])
                              
#RTdata$effector.code       =RTdata$effector.code-mean(RTdata$effector.code)
#RTdata$target_selected.code=RTdata$target_selected.code-mean(RTdata$target_selected.code)
#RTdata$choice.code         =RTdata$choice.code-mean(RTdata$choice.code)
  


#mRT2.code <- lmer(RT ~ effector.code*target_selected.code*choice.code*z.num_delay + (1+effector.code*target_selected.code*choice.code*z.num_delay||subj), 
#             data = RTdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


####################### get the null model

mRT2.null <- lmer(RT ~ z.num_delay*target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), 
             data = RTdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

as.data.frame(stats::anova(mRT2.null,mRT2, test="Chisq")) #Null model in random part identisch, in fixed effect nur was übrig ist 


###### inv.gaussian

# NUll 1
gRTig.null <- glmer(RT ~ z.num_delay*target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
               family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

as.data.frame(stats::anova(gRTig.null,gRTig, test="Chisq")) 


# releved side
RTdata$target_selected_2 = relevel(RTdata$target_selected, ref="right")
gRTig.null.relvl <- glmer(RT ~ z.num_delay*target_selected_2 + (1+ effector*target_selected_2*choice*z.num_delay|subj), data = RTdata,
                          family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

as.data.frame(stats::anova(gRTig.null.relvl,gRTig, test="Chisq")) 


# Null 2
gRTig.null2 <- glmer(RT ~ target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
                    family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

as.data.frame(stats::anova(gRTig.null2,gRTig, test="Chisq")) 


#################### find the model


gRTig.no4 <- glmer(RT ~ (effector+choice+target_selected+z.num_delay)^3 + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
               family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


gRTig.no3 <- glmer(RT ~ (effector+choice+target_selected+z.num_delay)^2 + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
                   family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

gRTig.no2.1 <- glmer(RT ~ effector+choice+target_selected+z.num_delay+effector:choice+effector:target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
                   family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

gRTig.no2.2 <- glmer(RT ~ effector+choice+target_selected+z.num_delay+effector:choice + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
                     family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))



# estis_gRTig.no2.1 <- boot.lmer(gRTig.no2.1, discard.warnings=T, nboots=500, para=T, resol=5,level=0.95,
#                         n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
#                         use = list(c("effector", "choice"),c("effector", "target_selected")))

library(lmerTest)
gRT_sig<- glmer(RT ~ effector+choice+target_selected+z.num_delay+effector:choice+effector:target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
                     family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


# save(mlog,step_mlog,final_mlog,RTdata, gRTig, gRTig.null, gRTig.null2, gRTig.no2.1, gRTig.no2.2, file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/behavioral_data/RT_statsRT_models.rda")
# load("Y:/MRI/Human/fMRI-reach-decision/Experiment/behavioral_data/RT_statsRT_models.rda")


######################### post hoc

# RTdata$eff_choi<-as.factor(paste(RTdata$effector,RTdata$choice,sep="_"))
# RTdata$eff_side<-as.factor(paste(RTdata$effector,RTdata$target_selected,sep="_"))
# 
# 
# 
# # eff:choi
# gRT_sig_effchoi <- glmer(RT ~ eff_choi+target_selected+z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
#                              family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
# 
# postHoc_effchoi <- emmeans(gRT_sig_effchoi, list(pairwise ~ eff_choi),adjust = "tukey")
# 
# summary(postHoc_effchoi)
# summary(postHoc_effchoi,type = "response")
# 
# # eff_target_selected
# gRT_sig_effside <- glmer(RT ~ eff_side+choice+z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
#                          family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
# 
# postHoc_effside <- emmeans(gRT_sig_effside, list(pairwise ~ eff_side),adjust = "tukey")

########### post hoc easy

postHoc_final <- emmeans(gRTig.no2.2, list(pairwise ~ choice:effector),adjust = "tukey", type = "response")




test <- glmer(RT ~ effector+choice+target_selected+z.num_delay+effector:choice:target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), data = RTdata,
                     family = inverse.gaussian(link = "log"),control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


######################### log transformed linear


library(lmerTest)

mlog <- lmer(log_RT ~ effector*target_selected * choice*z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), 
             data = RTdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

mlog_null <- lmer(log_RT ~ target_selected + (1+ effector*target_selected*choice*z.num_delay|subj), 
            data = RTdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


step_mlog <- step(mlog, reduce.random = FALSE, keep = c("effector","target_selected","choice","z.num_delay"),
                 control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

final_mlog <- get_model(step_mlog)




detach(name="package:lmerTest")
library(lme4)

mlog_lme4 <- lmer(log_RT ~ effector*target_selected * choice*z.num_delay + (1+ effector*target_selected*choice*z.num_delay|subj), 
             data = RTdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

estis_mlog <- boot.lmer(mlog_lme4, discard.warnings=T, nboots=1000, para=T, resol=5,level=0.95,
                   n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,  
                   use = list(c("effector", "target_selected", "choice","z.num_delay"),c("effector", "target_selected", "choice"),c("effector", "choice"),c("effector", "target_selected")))




######################### old stuff 

#t  <- lmer(RT ~ effector*choice*target_selected*num_delay + (target_selected|subj), data = RTdata, REML = FALSE,control = lmerControl(optimizer ="Nelder_Mead"))

summary(mRT)
anova(mRT) # significant interaction effector:num_delay (and almost significant effector:choice) --> separate models for effector

mRT_reach  <- lmer(RT ~ choice*target_selected*num_delay + (1|subj), data = RTdata[RTdata$effector == 'reach',], REML = FALSE)
mRT_sac    <- lmer(RT ~ choice*target_selected*num_delay + (1|subj), data = RTdata[RTdata$effector == 'saccade',], REML = FALSE)
anova(mRT_reach)
anova(mRT_sac)


## linear mixed effect model -->  delay as random

mRT_2 <- lmer(RT ~ effector*choice*target_selected+ (1|num_delay) + (1|subj), data = RTdata, REML = FALSE)
summary(mRT_2)
anova(mRT_2) # significant interaction effector:num_delay and significant effector:choice --> separate models for reach + saccade

mRT_reach_2  <- lmer(RT ~ choice*target_selected + (1|num_delay) + (1|subj), data = RTdata[RTdata$effector == 'reach',], REML = FALSE)
mRT_sac_2    <- lmer(RT ~ choice*target_selected + (1|num_delay) + (1|subj), data = RTdata[RTdata$effector == 'saccade',], REML = FALSE)
anova(mRT_reach_2)
anova(mRT_sac_2)



