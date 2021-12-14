

# behavioral analysis reaction times

library(readr)
library(lme4)
library(lmerTest)
library("R.matlab")
########

CEdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/Exp_era_period_diff_choi_instr.csv")

CEdata$effector  = factor(CEdata$cond)
CEdata$num_delay = CEdata$delay
CEdata$delay     = factor(CEdata$delay)
CEdata$subj      = factor(CEdata$subj)
CEdata$voi       = factor(CEdata$voi)
CEdata$period    = factor(CEdata$period)
CEdata$subj_period = factor(CEdata$subj_period)
CEdata$subj_delay<-as.factor(paste(CEdata$delay,CEdata$subj,sep="_"))

CEdata$z.num_delay=as.vector(scale(CEdata$num_delay)) # z-transformation
CEdata$effector_rlvl = relevel(CEdata$effector, ref='sac')
CEdata$period_rlvl = relevel(CEdata$period, ref='late')

# delay -1 0 1
CEdata$z_delay <- as.numeric(CEdata$delay)
CEdata$z_delay <- CEdata$z_delay -2

# t1 t2 t3 t4
CEdata$per_2 <- CEdata$num_delay 
idx = CEdata$period == 'early'
CEdata[idx,"per_2"] <- 4
CEdata$per_2 <- factor(CEdata$per_2)
CEdata$subj_per2<-as.factor(paste(CEdata$per_2,CEdata$subj,sep="_"))

######## TEST THINGS
detach(name="package:lmerTest")
library(lme4)


ts <- lmer(diff ~ effector*per_2 + (effector*per_2|subj), 
           data = CEdata,subset = (voi_number == 160),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

ts2 <- lmer(diff ~ effector*per_2*z_delay + (effector*per_2|subj), 
           data = CEdata,subset = (voi_number == 160),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))





test <- lmer(diff ~ effector*period*num_delay + (effector+period+num_delay|subj_period), 
             data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


testn <- lmer(diff ~ effector*period*delay + (effector+period+delay|subj_period), 
             data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


#tesu <- lmer(diff ~ effector*period*num_delay + (effector+period+num_delay|period) + (effector+period+num_delay|subj), 
#             data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


#test2 <- lmer(diff ~ period_rlvl+num_delay+effector + (effector+period+num_delay|subj_period), 
#             data = CEdata,subset = (voi_number == 11),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


test_step <- step(test, reduce.random = FALSE, keep = c("effector","period","num_delay"),
                 control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

testn_step <- step(testn, reduce.random = FALSE, keep = c("effector","period","delay"),
                  control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=1000000)))


test_final <- get_model(test_step)
anova(test_final)
summary(test_final)

testn_final <- get_model(testn_step)
anova(testn_final)
summary(testn_final)


test_estis <- boot.lmer(test, discard.warnings=T, nboots=1000, para=T, resol=3,
                   level=0.95,
                   n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
                   use = c("period"))


tess <- lmer(diff ~ effector*period*num_delay-effector:num_delay + (effector+period+num_delay|subj_period), 
             data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))



##########
ce10 <- lmer(diff ~ effector*period*num_delay + (effector+period+num_delay|subj_period), 
              data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

ce10.no2 <- lmer(diff ~ (effector+period+num_delay) + (effector+period+num_delay|subj_period), 
             data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


ce10.2 <- lmer(diff ~ effector*period*delay + (effector+period+delay|subj_period), 
               data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

anova(ce10,ce10.2)


ce101 <- lmer(diff ~ effector*period + (effector+period|subj_period), 
             data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

ce101.no2 <- lmer(diff ~ effector+period + (effector+period|subj_period), 
                  data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

ce101.2 <- lmer(diff ~ effector*period + (effector+period|subj_period), 
              data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


#######

step_ce10 <- step(ce10, reduce.random = FALSE, keep = c("effector","period","num_delay"),
                  control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

step_ce10.2 <- step(ce10.2, reduce.random = FALSE, keep = c("effector","period","delay"),
                    control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))



step_ce101 <- step(ce101, reduce.random = FALSE, keep = c("effector","period"),
                  control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

summary(get_model(step_ce10))
summary(get_model(step_ce10.2))
summary(get_model(step_ce101))

anova(get_model(step_ce10))
anova(get_model(step_ce10.2))
anova(get_model(step_ce101))
#############



# CEdata$kombi<-as.factor(paste(CEdata$effector,CEdata$period,CEdata$num_delay,sep="_"))




test <- boot.lmer(ce10, discard.warnings=T, nboots=10, para=F, resol=3,
          level=0.95,
          n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
          use=c("effector", "period","num_delay"),use.u=F)



#response = c0 + c1*delay + c2*period + c3*delay*period    # --> period ausmultiplizieren

#response = (c0 + c1 * delay) + (c2 + c3*delay) * period

# 0.0069416071 --> effect von period wenn delay = 0

#response = (0.1875712268   + -0.0066393287 * 9) + (0.0069416071 + -0.0036046786 * 9) * period  # --> unterschied zwischen early und late delay = 9 
#                                                 ( = effekt von period wenn delay = 9)


d <- list()
lvls <- unique(CEdata$voi_number)
CEfitted <- data.frame()
CEestis <- data.frame()

for (i in 1:length(lvls))
{
  detach(name="package:lmerTest")
  library(lme4)

  mce4 <- lmer(diff ~ effector*period*num_delay + (effector+period+num_delay|subj_period),
              data = CEdata, REML = FALSE,subset = (voi_number == lvls[i]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

  estis <- boot.lmer(mce4, discard.warnings=T, nboots=1000, para=T, resol=3,
                     level=0.95,
                     n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
                     use = c("effector", "period", "num_delay"))

  estis$ci.fitted$voi_number    <- rep(x = lvls[i],nrow(estis$ci.fitted))
  estis$ci.estimates$voi_number <- rep(x = lvls[i],nrow(estis$ci.estimates))
  estis$ci.estimates$names <- rownames(estis$ci.estimates)

  # put in in list
  d$model[[i]] <- mce4
  d$estis[[i]] <- estis$ci.estimates
  d$fitted[[i]] <- estis$ci.fitted
  d$voi_number[[i]] <- lvls[i]


  # put it in tables
  CEfitted <- rbind(CEfitted,d$fitted[[i]])
  CEestis  <- rbind(CEestis,d$estis[[i]])

  # get lmerTest model
  library(lmerTest)

  mceT <- lmer(diff ~ effector*period*num_delay + (effector+period+num_delay|subj_period),
               data = CEdata, REML = FALSE,subset = (voi_number == lvls[i]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

  step_mceT <- step(mceT, reduce.random = FALSE, keep = c("effector","period","num_delay"),
                    control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

  final_mceT <- get_model(step_mceT)

  d$mod_sig[[i]]       <- mceT
  d$mod_sig_step[[i]]  <- step_mceT
  d$mod_sig_final[[i]] <- final_mceT


}

save(d, CEfitted, CEestis, file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/choice_effect_models.rda")

writeMat('Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CEfitted_numdelay.mat', CEfitted=CEfitted)
writeMat('Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CEestis_numdelay.mat', CEestis=CEestis)

capture.output({"ANOVA tables of final model, coded with numerical delay"},file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_final_models_num_delay.txt",append = FALSE)

for (i in 1:21){
  capture.output(d$voi_number[[i]],file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_final_models_num_delay.txt",append = TRUE)
  capture.output(anova(d$mod_sig_final[[i]]),file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_final_models_num_delay.txt",append = TRUE)
}


#################


for (i in 1:21)
{
  
  estis_noDel <- boot.lmer(d$model[[i]], discard.warnings=T, nboots=1000, para=T, resol=3,
                     level=0.95,
                     n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
                     use = c("effector", "period"))
  
  estis_noDel$ci.fitted$voi_number    <- rep(x = lvls[i],nrow(estis_noDel$ci.fitted))
  estis_noDel$ci.estimates$voi_number <- rep(x = lvls[i],nrow(estis_noDel$ci.estimates))
  estis_noDel$ci.estimates$names      <- rownames(estis_noDel$ci.estimates)
  
  d$estis_noDel[[i]]  <- estis_noDel$ci.estimates
  d$fitted_noDel[[i]] <- estis_noDel$ci.fitted
  
}
save(d, CEfitted, CEestis, file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/choice_effect_models.rda")


####################################### categorical delay
# 
# f <- list()
# lvls <- unique(CEdata$voi_number)
# CEfitted <- data.frame()
# CEestis <- data.frame()
# 
# for (i in 1:length(lvls))
# {
#   detach(name="package:lmerTest")
#   library(lme4) 
#   
#   mce4 <- lmer(diff ~ effector*period*delay + (effector+period+delay|subj_period), 
#                data = CEdata, REML = FALSE,subset = (voi_number == lvls[i]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
#   
#   estis <- boot.lmer(mce4, discard.warnings=T, nboots=1000, para=T, resol=3,
#                      level=0.95,
#                      n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
#                      use = c("effector", "period", "delay"))
#   
#   estis$ci.fitted$voi_number    <- rep(x = lvls[i],nrow(estis$ci.fitted))
#   estis$ci.estimates$voi_number <- rep(x = lvls[i],nrow(estis$ci.estimates))
#   estis$ci.estimates$names <- rownames(estis$ci.estimates)
#   
#   # put in in list
#   f$model[[i]] <- mce4
#   f$estis[[i]] <- estis$ci.estimates
#   f$fitted[[i]] <- estis$ci.fitted
#   f$voi_number[[i]] <- lvls[i]
#   
#   
#   # put it in tables
#   CEfitted <- rbind(CEfitted,f$fitted[[i]])
#   CEestis  <- rbind(CEestis,f$estis[[i]])
#   
#   # get lmerTest model
#   library(lmerTest)
#   
#   mceT <- lmer(diff ~ effector*period*delay + (effector+period+delay|subj_period), 
#                data = CEdata, REML = FALSE,subset = (voi_number == lvls[i]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
#   
#   step_mceT <- step(mceT, reduce.random = FALSE, keep = c("effector","period","delay"),
#                     control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
#   
#   final_mceT <- get_model(step_mceT)
#   
#   f$mod_sig[[i]]       <- mceT
#   f$mod_sig_step[[i]]  <- step_mceT
#   f$mod_sig_final[[i]] <- final_mceT
#   
#   
# }
# 
# save(f, CEfitted, CEestis, file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/choice_effect_models_catdelay.rda")
# 
# writeMat('Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CEfitted_catdelay.mat', CEfitted=CEfitted)
# writeMat('Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CEestis_catdelay.mat', CEestis=CEestis)
# 
# capture.output({"ANOVA tables of final model, coded with categorical delay"},file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_final_models_cat_delay.txt",append = FALSE)
# 
# for (i in 1:21){
#   capture.output(f$voi_number[[i]],file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_final_models_cat_delay.txt",append = TRUE)
#   capture.output(anova(f$mod_sig_final[[i]]),file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_final_models_cat_delay.txt",append = TRUE)
# }


########## post hoc

CEdata$kombi<-as.factor(paste(CEdata$effector,CEdata$period,CEdata$num_delay,sep="_"))

# "reach_early_12" "reach_early_15" "reach_early_9"  "reach_late_12"  "reach_late_15"  "reach_late_9"   
# "sac_early_12"   "sac_early_15"   "sac_early_9" "sac_late_12"    "sac_late_15"    "sac_late_9"    


library(lmerTest)

detach(name="package:lmerTest")
library(lme4)

m_ph <- lmer(diff ~ 0+ kombi + (1 + effector+period+num_delay|subj_period),
             data = CEdata, REML = FALSE,subset = (voi_number == lvls[2]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

summary(m_ph)

library(multcomp)

contr<-diag(length(levels(CEdata$kombi)))
contr[ ,1] <- rep(1)
rownames(contr) <- levels(CEdata$kombi)


summary(glht(m_ph,contr))

grr <- lmer(diff ~ 1+ effector + (1 + effector+period+num_delay|subj_period),
             data = CEdata, REML = FALSE,subset = (voi_number == lvls[1]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000))) 

test <- model.matrix(grr)
