

# behavioral analysis reaction times

library(readr)
library(lme4)
library(lmerTest)
library(ggplot2)



MRdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/Exp_era_period_average_43-SCEF_l_Cluster0001_-8_15_48_.csv")


MRdata$period = factor(MRdata$period)
MRdata$cond = factor(MRdata$cond)
MRdata$eff = factor(MRdata$eff)
MRdata$choi = factor(MRdata$choi)
MRdata$side = factor(MRdata$side)
MRdata$num_delay = MRdata$delay
MRdata$delay = factor(MRdata$delay)
MRdata$subj = factor(MRdata$subj)
MRdata$voi = factor(MRdata$voi)
MRdata$trial_id = factor(MRdata$trial_id)
MRdata$value = MRdata$mean

MRdata$z.num_delay=as.vector(scale(MRdata$num_delay)) # z-transformation

########

diffMRdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/Exp_era_period_diff_43-SCEF_l_Cluster0001_-8_15_48_.csv")

diffMRdata$cond = factor(diffMRdata$cond)
diffMRdata$eff = factor(diffMRdata$eff)
diffMRdata$choi = factor(diffMRdata$choi)
diffMRdata$side = factor(diffMRdata$side)
diffMRdata$num_delay = diffMRdata$delay
diffMRdata$delay = factor(diffMRdata$delay)
diffMRdata$subj = factor(diffMRdata$subj)
diffMRdata$voi = factor(diffMRdata$voi)

diffMRdata$z.num_delay=as.vector(scale(diffMRdata$num_delay)) # z-transformation

########


modMR <- lmer(value ~ period*eff*choi*side*z.num_delay + (1+ eff*choi*side*z.num_delay|period/subj), 
              data = MRdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))




diffMR_side <- lmer(diff ~ eff*choi*side*z.num_delay + (1+ eff*choi*side*z.num_delay|subj), 
               data = diffMRdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

diffMR <- lmer(diff ~ eff*choi*num_delay + (1+ eff*choi*num_delay|subj), 
                    data = diffMRdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


#qqnorm(residuals(diffMR));qqline(residuals(diffMR))
#hist(residuals(diffMR))
#hist(diffMRdata$diff)

#plot(residuals(diffMR), fitted(diffMR),pch=19, col=grey(level=0.7, alpha=0.2))
#summary(diffMR)$varcor

#nrow(as.data.frame(summary(diffMR)$varcor))
#length(fixef(diffMR))
#length(residuals(diffMR))


diffMR <- lmer(diff ~ (eff+choi+num_delay)^2 + (1+ eff*choi*num_delay|subj), 
               data = diffMRdata, REML = FALSE, control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))










