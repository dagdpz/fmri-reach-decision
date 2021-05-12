require(multcomp)

mRT_5c_cnt <- lmer(RT ~ kombi + (1|subj), data = RTdata, REML = FALSE)#,control=lmerControl(optCtrl = list(maxfun = 1e6),optimizer="bobyqa"))

levels(RTdata$kombi)


# "reach_choice_left"        "reach_choice_right"       "reach_instructed_left"    "reach_instructed_right"   
# "saccade_choice_left"      "saccade_choice_right"     "saccade_instructed_left"  "saccade_instructed_right"


contr<-rbind(
  c(0,0,0,0, 1,1,-1,-1) # saccade: choice vs. instructed
  ,c(1,1,-1,-1,0,0,0,0) # reach: choice vs. instructed
  
  ,c(0,0,0,0, 1,-1,-1,1) # saccade: Is choice vs. instructed different for left vs. right?
  ,c(1,-1,-1,1,0,0,0,0) # reach: Is choice vs. instructed different for left vs. right?
  
  ,c(0,0,0,0, 0,1,0,-1) # saccade right: choice vs. instructed  
  ,c(0,0,0,0, 1,0,-1,0) # saccade left: choice vs. instructed
  
  ,c(0,1,0,-1, 0,0,0,0) # reach right: choice vs. instructed
  ,c(1,0,-1,0, 0,0,0,0) # reach left: choice vs. instructed  
  
  ,c(0,0,0,0, -1,1,0,0)  #  saccade choice:     right minus left 
  ,c(0,0,0,0, 0,0,-1,1) #  saccade instructed: right minus left  
  ,c(-1,1,0,0, 0,0,0,0) #  reach choice:        righ  minus left  
  ,c(0,0,-1,1, 0,0,0,0) #  reach instructed:    right minus left  
  
  
)

summary(glht(mRT_5c_cnt,linfct=mcp(kombi=contr)),test=adjusted("none"))
summary(glht(mRT_5c_cnt,linfct=mcp(kombi=contr)))

summary(glht(mRT_5c_cnt,linfct=mcp(kombi="Tukey")),test=adjusted("none"))
summary(glht(mRT_5c_cnt,linfct=mcp(kombi="Tukey")))




##




mRT_1_delay  <- lmer(RT ~ delay*effector*choice*target_selected + (1|subj), data = RTdata, REML = FALSE)

mRT_2_delay  <- lmer(RT ~ delay*effector*choice*target_selected + (delay*effector|subj), data = RTdata, REML = FALSE)




RTdata$kombi_delay<-as.factor(paste(RTdata$delay,RTdata$effector,RTdata$choice,RTdata$target_selected,sep="_"))
mRT_1_delay_cnt  <- lmer(RT ~ kombi_delay + (1|subj), data = RTdata, REML = FALSE)


levels(RTdata$kombi_delay)

# [1] "12_reach_choice_left"        "12_reach_choice_right"       "12_reach_instructed_left"    "12_reach_instructed_right"  
# [5] "12_saccade_choice_left"      "12_saccade_choice_right"     "12_saccade_instructed_left"  "12_saccade_instructed_right"

# [9] "15_reach_choice_left"        "15_reach_choice_right"       "15_reach_instructed_left"    "15_reach_instructed_right"  
# [13] "15_saccade_choice_left"      "15_saccade_choice_right"     "15_saccade_instructed_left"  "15_saccade_instructed_right"

# [17] "3_reach_choice_left"         "3_reach_choice_right"        "3_reach_instructed_left"     "3_reach_instructed_right"   
# [21] "3_saccade_choice_left"       "3_saccade_choice_right"      "3_saccade_instructed_left"   "3_saccade_instructed_right" 

# [25] "6_reach_choice_left"         "6_reach_choice_right"        "6_reach_instructed_left"     "6_reach_instructed_right"   
# [29] "6_saccade_choice_left"       "6_saccade_choice_right"      "6_saccade_instructed_left"   "6_saccade_instructed_right" 

# [33] "9_reach_choice_left"         "9_reach_choice_right"        "9_reach_instructed_left"     "9_reach_instructed_right"   
# [37] "9_saccade_choice_left"       "9_saccade_choice_right"      "9_saccade_instructed_left"   "9_saccade_instructed_right" 


contr_delay<-rbind(
  c(0,0,0,0, 1,1,-1,-1,0,0,0,0, 1,1,-1,-1,0,0,0,0, 1,1,-1,-1,0,0,0,0, 1,1,-1,-1,0,0,0,0, 1,1,-1,-1) # saccade: choice vs. instructed
  ,c(1,1,-1,-1,0,0,0,0,1,1,-1,-1,0,0,0,0,1,1,-1,-1,0,0,0,0,1,1,-1,-1,0,0,0,0,1,1,-1,-1,0,0,0,0) # reach: choice vs. instructed
  
  ,c(0,0,0,0, 1,-1,-1,1,0,0,0,0, 1,-1,-1,1,0,0,0,0, 1,-1,-1,1,0,0,0,0, 1,-1,-1,1,0,0,0,0, 1,-1,-1,1) # saccade: Is choice vs. instructed different for left vs. right?
  ,c(1,-1,-1,1,0,0,0,0,1,-1,-1,1,0,0,0,0,1,-1,-1,1,0,0,0,0,1,-1,-1,1,0,0,0,0,1,-1,-1,1,0,0,0,0) # reach: Is choice vs. instructed different for left vs. right?

  ,c(0,0,0,0, 0,1,0,-1,0,0,0,0, 0,1,0,-1,0,0,0,0, 0,1,0,-1,0,0,0,0, 0,1,0,-1,0,0,0,0, 0,1,0,-1) # saccade right: choice vs. instructed
  ,c(0,0,0,0, 1,0,-1,0,0,0,0,0, 1,0,-1,0,0,0,0,0, 1,0,-1,0,0,0,0,0, 1,0,-1,0,0,0,0,0, 1,0,-1,0) # saccade left: choice vs. instructed

  ,c(0,1,0,-1, 0,0,0,0,0,1,0,-1, 0,0,0,0,0,1,0,-1, 0,0,0,0,0,1,0,-1, 0,0,0,0,0,1,0,-1, 0,0,0,0) # reach right: choice vs. instructed
  ,c(1,0,-1,0, 0,0,0,0,1,0,-1,0, 0,0,0,0,1,0,-1,0, 0,0,0,0,1,0,-1,0, 0,0,0,0,1,0,-1,0, 0,0,0,0) # reach left: choice vs. instructed

  ,c(0,0,0,0, -1,1,0,0,0,0,0,0, -1,1,0,0,0,0,0,0, -1,1,0,0,0,0,0,0, -1,1,0,0,0,0,0,0, -1,1,0,0)  #  saccade choice:     right minus left
  ,c(0,0,0,0,  0,0,-1,1,0,0,0,0, 0,0,-1,10,0,0,0,  0,0,-1,10,0,0,0,  0,0,-1,1,0,0,0,0, 0,0,-1,1) #  saccade instructed: right minus left
  ,c(-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0) #  reach choice:        righ  minus left
  ,c(0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0) #  reach instructed:    right minus left
  
  
)

contr_delay<-rbind(
  c(0,0,0,0, 1,1,-1,-1,0,0,0,0, 1,1,-1,-1,0,0,0,0, 0,0,0,0,0,0,0,0, 1,1,-1,-1,0,0,0,0, 1,1,-1,-1) # saccade: choice vs. instructed
  ,c(1,1,-1,-1,0,0,0,0,1,1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,-1,-1,0,0,0,0,1,1,-1,-1,0,0,0,0) # reach: choice vs. instructed
  
  ,c(0,0,0,0, 1,-1,-1,1,0,0,0,0, 1,-1,-1,1,0,0,0,0, 0,0,0,0,0,0,0,0, 1,-1,-1,1,0,0,0,0, 1,-1,-1,1) # saccade: Is choice vs. instructed different for left vs. right?
  ,c(1,-1,-1,1,0,0,0,0,1,-1,-1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,-1,-1,1,0,0,0,0,1,-1,-1,1,0,0,0,0) # reach: Is choice vs. instructed different for left vs. right?
  
  ,c(0,0,0,0, 0,1,0,-1,0,0,0,0, 0,1,0,-1,0,0,0,0, 0,0,0,0,0,0,0,0, 0,1,0,-1,0,0,0,0, 0,1,0,-1) # saccade right: choice vs. instructed
  ,c(0,0,0,0, 1,0,-1,0,0,0,0,0, 1,0,-1,0,0,0,0,0, 0,0,0,0,0,0,0,0, 1,0,-1,0,0,0,0,0, 1,0,-1,0) # saccade left: choice vs. instructed
  
  ,c(0,1,0,-1, 0,0,0,0,0,1,0,-1, 0,0,0,0,0,0,0,0, 0,0,0,0,0,1,0,-1, 0,0,0,0,0,1,0,-1, 0,0,0,0) # reach right: choice vs. instructed
  ,c(1,0,-1,0, 0,0,0,0,1,0,-1,0, 0,0,0,0,0,0,0,0, 0,0,0,0,1,0,-1,0, 0,0,0,0,1,0,-1,0, 0,0,0,0) # reach left: choice vs. instructed
  
  ,c(0,0,0,0, -1,1,0,0,0,0,0,0, -1,1,0,0,0,0,0,0, 0,0,0,0,0,0,0, -1,1,0,0,0,0,0,0, -1,1,0,0)  #  saccade choice:     right minus left
  ,c(1,0,-1,0, 0,0,-1,1,1,0,-1,0, 0,0,-1,1,1,0,-1,0, 0,0,-1,1,1,0,-1,0, 0,0,-1,1,1,0,-1,0, 0,0,-1,1) #  saccade instructed: right minus left
  ,c(-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0,-1,1,0,0, 0,0,0,0) #  reach choice:        righ  minus left
  ,c(0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0,0,0,-1,1, 0,0,0,0) #  reach instructed:    right minus left
  
  
)

summary(glht(mRT_1_delay_cnt,linfct=mcp(kombi_delay=contr_delay)),test=adjusted("none"))
summary(glht(mRT_1_delay_cnt,linfct=mcp(kombi_delay=contr_delay)))

