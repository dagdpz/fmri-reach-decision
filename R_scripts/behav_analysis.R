
library(readr)
library(lme4)
library(lmerTest)

RTdata <- read_csv("Y:/MRI/Human/fMRI-reach-decision/Experiment/behavioral_data/current_dat_file.csv")


Alldata = RTdata

# clean data
RTdata <- RTdata[RTdata$success == 1,]
RTdata <- RTdata[!(RTdata$RT == -99 | RTdata$RT > 0.8 | (RTdata$RT < 0.2 & RTdata$RT == 'saccade')),]

#

mRT_full <- lmer(RT ~ effector*choice*target_selected + (effector*choice*target_selected|subj) + (delay|subj), data = RTdata, REML = FALSE)

gRT_full <- glmer(RT ~ effector*choice*target_selected + (effector*choice*target_selected|subj) + (delay|subj), data = RTdata,family = inverse.gaussian)

summary(mRT_full)
summary(gRT_full)



fit <- fitDist(RTdata$RT, k = 2, type = "realplus", trace = FALSE, try.gamlss = TRUE)

summary(fit)