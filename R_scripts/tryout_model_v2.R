
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
CEdata$per_2 = relevel(CEdata$per_2, ref='4')

##### Make up data

#CEdata

CEnew = data.frame()

# t2 für 12 s delay
CEzw = data.frame()
sel = CEdata$per_2 == '9'
CEzw = as.data.frame(CEdata[sel,])
CEzw$z_delay = 0 # 12 s delay

rowz = sample(nrow(CEzw))
CEzw$diff = CEzw$diff[rowz]

CEnew = rbind(CEnew,CEzw)


# t2 für 15 s delay
CEzw = data.frame()
sel = CEdata$per_2 == '9'
CEzw = as.data.frame(CEdata[sel,])
CEzw$z_delay = 1 # 15 s delay

rowz = sample(nrow(CEzw))
CEzw$diff = CEzw$diff[rowz]

CEnew = rbind(CEnew,CEzw)


# t3 für 15 s delay
CEzw = data.frame()
sel = CEdata$per_2 == '12'
CEzw = as.data.frame(CEdata[sel,])
CEzw$z_delay = 1 # 15 s delay

rowz = sample(nrow(CEzw))
CEzw$diff = CEzw$diff[rowz]

CEnew = rbind(CEnew,CEzw)

# add old data

CEnew = rbind(CEnew,CEdata)
###### stats


ts1 <- lmer(diff ~ effector*per_2*z_delay + (effector*per_2|subj), 
           data = CEdata,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))


ts2 <- lmer(diff ~ effector*per_2*z_delay + (effector*per_2|subj), 
            data = CEnew,subset = (voi_number == 10),REML = FALSE,control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

anova(ts1)
anova(ts2)

ts1_step <- step(ts1, reduce.random = FALSE, keep = c("effector","per_2","z_delay"),
                  control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))

ts2_step <- step(ts2, reduce.random = FALSE, keep = c("effector","per_2","z_delay"),
                 control=lmerControl(optimizer="bobyqa", optCtrl=list(maxfun=100000)))
plot(ts1_step)
plot(ts2_step)

ts1_final = get_model(ts1_step)
ts2_final = get_model(ts2_step)

summary(ts1_final)
summary(ts2_final)

anova(ts1_final)
anova(ts2_final)

