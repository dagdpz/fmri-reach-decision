# export to csv



# load this "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/peak_instructed_models.rda"
# load this "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/choice_effect_models.rda"




model1_cond <- data.frame()
model2_time <- data.frame()



for (i in 1:21)
{
  
  outp1 <- as.data.frame(t$mod_sig_step[[i]]$fixed)
  outp1$voi_number <- rep(x = t$voi_number[[i]],nrow(outp1))
                         
  model1_cond <- rbind(model1_cond,outp1)
  
  outp2 <- as.data.frame(d$mod_sig_step[[i]]$fixed)
  outp2$voi_number <- rep(x = d$voi_number[[i]],nrow(outp2))  
  
  model2_time <- rbind(model2_time,outp2)
   
  
}

write.csv(model1_cond,file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/PI_anova_steps_model1_cond.csv")
write.csv(model2_time,file = "Y:/MRI/Human/fMRI-reach-decision/Experiment/MNI/stats/CE_anova_steps_model2_time.csv")
