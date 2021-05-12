
library(readr)
library(lme4)
library(lmerTest)
library(kyotil)
library("R.matlab")
source("Y:/Personal/Peter/R_scripts/boot_glmm.r")
library(emmeans)


PIdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/Exp_era_period_average.csv")


PIdata$effector = factor(PIdata$eff)
PIdata$subj = factor(PIdata$subj)
PIdata$voi = factor(PIdata$voi)
PIdata$choi = factor(PIdata$choi)
PIdata$side = factor(PIdata$side)
PIdata$cond = factor(PIdata$cond)

mpi <-  lmer(mean ~ eff*choi*side + (eff+choi+side|subj), data = PIdata, REML = FALSE,subset = (voi_number == 10), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
summary(mpi)

mpi.2<- lmer(mean ~ (eff+choi+side)^2 + (eff+choi+side|subj), data = PIdata, REML = FALSE,subset = (voi_number == 10))
summary(mpi.2)

mpi.3<- lmer(mean ~ (eff+choi+side)   + (eff+choi+side|subj), data = PIdata, REML = FALSE,subset = (voi_number == 10))
summary(mpi.3)


test <- boot.lmer(mpi, discard.warnings=T, nboots=10, para=F, resol=3,
          level=0.95,
          n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
          use = c("eff", "choi", "side"))




######## here it starts 

t <- list()
lvls <- unique(PIdata$voi_number)
PIfitted <- data.frame()
PIestis <- data.frame()

library(lmerTest)

for (i in 1:length(lvls))
{
  detach(name="package:lmerTest")
  library(lme4)
  
  mpi4 <- lmer(mean ~ eff*choi*side + (eff+choi+side|subj), 
              data = PIdata, REML = FALSE,subset = (voi_number == lvls[i]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

  estis <- boot.lmer(mpi4, discard.warnings=T, nboots=1000, para=T, resol=3,
                    level=0.95,
                    n.cores=c("all-1", "all"), circ.var.name=NULL, circ.var=NULL,
                    use = c("eff", "choi", "side"))
  
  estis$ci.fitted$voi_number    <- rep(x = lvls[i],nrow(estis$ci.fitted))
  estis$ci.estimates$voi_number <- rep(x = lvls[i],nrow(estis$ci.estimates))
  estis$ci.estimates$names <- rownames(estis$ci.estimates)
  
  # put in in list
  t$mod_fit[[i]]    <- mpi
  t$estis[[i]]      <- estis$ci.estimates
  t$fitted[[i]]     <- estis$ci.fitted
  t$voi_number[[i]] <- lvls[i]
  
  # put it in tables
  PIfitted <- rbind(PIfitted,t$fitted[[i]])
  PIestis  <- rbind(PIestis,t$estis[[i]])
  
  # get lmerTest model
  library(lmerTest)
  
  mpiT <- lmer(mean ~ eff*choi*side + (eff+choi+side|subj), 
               data = PIdata, REML = FALSE,subset = (voi_number == lvls[i]), control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
  
  step_mpiT <- step(mpiT, reduce.random = FALSE, keep = c("eff","choi","side"),
                   control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
  
  final_mpiT <- get_model(step_mpiT)
  
  t$mod_sig[[i]] <- mpiT
  t$mod_sig_step[[i]] <- step_mpiT
  t$mod_sig_final[[i]] <- final_mpiT
  

  
}

save(t, PIfitted, PIestis, file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/peak_instructed_models.rda")

writeMat('Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/PIfitted.mat', PIfitted=PIfitted)
writeMat('Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/PIestis.mat', PIestis=PIestis)


##################### write in anovas in txt file

capture.output({"ANOVA tables of final model, coded with categorical delay"},file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/PI_final_models.txt",append = FALSE)

for (i in 1:21){
  capture.output(t$voi_number[[i]],file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/PI_final_models.txt",append = TRUE)
  capture.output(anova(t$mod_sig_final[[i]]),file="Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/PI_final_models.txt",append = TRUE)
}




######################### post hoc

# eff:side

ph_rInsula <- emmeans(t$mod_sig_final[[20]], list(pairwise ~ choi|side),adjust = "tukey")

summary(ph_rInsula)
summary(ph_rInsula,type = "response")


