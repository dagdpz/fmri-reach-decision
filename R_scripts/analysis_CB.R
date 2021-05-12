
library(readr)
library(lme4)

CBdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/behavioral_data/choice_bias.csv")

CBdata$effector = factor(CBdata$effector)
CBdata$subj     = factor(CBdata$subj)


mCB = lmer(choice_bias_diff ~ effector + (1 |subj),data = CBdata,REML = FALSE)

summary(mCB)

## diagnostics mCB
#qqnorm(residuals(mCB));qqline(residuals(mCB))
#hist(residuals(mCB))
#hist(CBdata$choice_bias_diff)

#plot(residuals(mCB), fitted(mCB),pch=19, col=grey(level=0.7, alpha=0.8))
#summary(mCB)$varcor


CBdata$effector_rlvl = relevel(CBdata$effector, ref="saccade")
mCB_rlvl  = lmer(choice_bias_diff ~ effector_rlvl + (1 |subj),data = CBdata,REML = FALSE)


summary(mCB)
summary(mCB_rlvl)


save.image(file='Choice_bias_workspace.RData')
