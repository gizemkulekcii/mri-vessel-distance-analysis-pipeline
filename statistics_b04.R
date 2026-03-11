
# Load necessary libraries
library(caret)
library(ggplot2)
library(dplyr) #For data manipulation
library(car) #For post hoc tests
library(ggpubr) #For publication-ready plots

# Read the data
#vdm <- read.csv("vdm.csv", header = TRUE, sep = ",")
#z03 <- read.csv("z03_data_4gizem.csv", header = TRUE, sep = ",")

# Merge datasets by subject ID
#merged_data <- merge(z03, vdm, by.x = "subject_id", by.y = "X", all.x = TRUE)

# Create a new column: average vessel distance(avg_vd) from two columns
#merged_data$avg_vd <- rowMeans(cbind(merged_data$HC_all_le_gvdm_mean, merged_data$HC_all_ri_gvdm_mean), na.rm = TRUE)

# Write the merged data to CSV
#write.csv(merged_data, "merged_data.csv", row.names = FALSE)

# Read the updated merged data
merged_data <-read.csv("merged_data.csv", header = TRUE, sep = ",")

# Exploratory data analysis: Mean, Median, and Histograms
mean_avg_vd <- mean(merged_data$avg_vd, na.rm =  TRUE)
median_avg_vd <- median(merged_data$avg_vd, na.rm =  TRUE)
sd_avg_vd <- sd(merged_data$avg_vd, na.rm =  TRUE)

# Print Mean, Median, and SD
cat("Mean of Average Vessel Distance:", mean_avg_vd, "\n")
cat("Median of Average Vessel Distance:", median_avg_vd, "\n")
cat("Standard Deviation of Average Vessel Distance:", sd_avg_vd, "\n")

# Visualize Histogram of Average Vessel Distance
ggplot(merged_data, aes(x = avg_vd)) +
  geom_histogram(binwidth = 0.5, fill = "blue", color = "black") +
  labs(title = "Histogram of Average Vessel Distance", x = "Average Vessel Distance", y = "Frequency") +
  theme_minimal()

# Check normality of average vessel distance
normality_vd <- shapiro.test(merged_data$avg_vd)

# Visualize the volume (vol_wHC_bi) variable
ggplot(merged_data, aes(x = vol_wHC_bi)) +
  geom_histogram(binwidth = 300, fill = "green", color = "black") +
  labs(title = "Histogram of Volume (vol_wHC_bi)", x = "Volume", y = "Frequency") +
  theme_minimal()

# Convert 'sex' and 'SA_verbal_binary' to factors with appropriate labels
merged_data$sex <- factor(merged_data$sex, levels = c(-1,1), labels = c("female","male"))
merged_data$SA_verbal_binary<- factor(merged_data$SA_verbal_binary, levels = c(0,1,2), labels = c("OA","TA","SA"))

#class(merged_data$sex)
#class(merged_data$SA_verbal_binary)


# Association with demographics: Age, Sex, Education Years

# Correlation and linear model for Age
cor_age <- cor(merged_data$avg_vd, merged_data$age, use = 'complete.obs') 
plot(merged_data$age, merged_data$avg_vd, main = "Avg Vessel Distance vs Age", xlab = "Age", ylab = "Average Vessel Distance")
model_age <- lm(age ~ avg_vd, data = merged_data, na.action = na.exclude)
abline(model_age)
summary(model_age)

# Correlation and linear model for Education Years
cor_edu <- cor(merged_data$avg_vd, merged_data$edu_yrs, use = 'complete.obs') 
plot(merged_data$edu_yrs, merged_data$avg_vd, main = "Average Vessel Distance vs Education Years", xlab = "Education Years", ylab = "Average Vessel Distance")
model_edu <- lm(edu_yrs ~ avg_vd, data= merged_data, na.action = na.exclude)
abline(model_edu)
summary(model_edu)

#T-test for Sex
t_test_sex <- t.test(avg_vd ~ sex, data = merged_data)
print(t_test_sex)
ggplot(merged_data, aes(x = sex, y = avg_vd)) +
  geom_boxplot() +
  labs(title = "Average Vessel Distance by Sex", 
       x ="Sex",
       y= "Average Vessel Distance")+
  theme_minimal()
      

# Association with Cognition: 
# CERAD Global Cognition Score
merged_data_cerad <- merged_data[!is.na(merged_data$CERAD_mean_Zscores), ]
cor_cerad <- cor(merged_data_cerad$avg_vd, merged_data_cerad$CERAD_mean_Zscores, use = 'complete.obs') #0.0578

# Linear model with covariates: age, sex, and education
model_cerad <- lm(CERAD_mean_Zscores ~ avg_vd + age + sex + edu_yrs , data= merged_data_cerad)
summary(model_cerad)

# Plot CERAD Global Cognition Score vs Average Vessel Distance
ggplot(merged_data_cerad, aes(x = CERAD_mean_Zscores, y = avg_vd)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Average Vessel Distance vs CERAD",
       x = "CERAD mean Z scores",
       y = "Average Vessel Distance") +
  theme_minimal()

# VLMT(Verbal Memory)
merged_data_vlmt <- merged_data[!is.na(merged_data$NP2_tp1_VLMT_Dg7_RW), ]
cor_vlmt <- cor( merged_data_vlmt$avg_vd,  merged_data_vlmt$NP2_tp1_VLMT_Dg7_RW, use = 'complete.obs') #0.328

# Linear model with covariates
model_vlmt <- lm(NP2_tp1_VLMT_Dg7_RW ~ avg_vd + age +sex + edu_yrs , data= merged_data_vlmt)
summary(model_vlmt)

# Plot VLMT vs Average Vessel Distance
ggplot(merged_data_vlmt, aes(x = NP2_tp1_VLMT_Dg7_RW, y = avg_vd)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Average Vessel Distance vs VLMT",
       x = "VLMT",
       y = "Average Vessel Distance") +
  theme_minimal()

# RCFT: Figural Memory
merged_data_rcft <- merged_data[!is.na(merged_data$NP2_tp1_VLMT_Dg7_RW), ]
cor_rcft <- cor(merged_data_rcft$avg_vd, merged_data_rcft$NP2_tp1_RCFT_DR_RW, use = 'complete.obs') #0.0525

# Linear model with covariates
model_rcft <- lm(NP2_tp1_RCFT_DR_RW~ avg_vd + age + sex + edu_yrs , data= merged_data_rcft)
summary(model_rcft)

# Plot RCFT vs Average Vessel Distance
ggplot(merged_data_rcft, aes(x = avg_vd, y = NP2_tp1_RCFT_DR_RW)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Average Vessel Distance vs RCFT",
       x = "Average Vessel Distance",
       y = "RCFT") +
  theme_minimal()

#Super Ager Status: ANOVA and post hoc test
anova_sa <- aov(avg_vd ~ SA_verbal_binary + sex, data = merged_data)
summary(anova_sa)

# Post hoc test
post_hoc <- TukeyHSD(anova_sa)
print(post_hoc)

# Plot Super Ager Status with covariates
ggplot(merged_data, aes(x = SA_verbal_binary, y = avg_vd, fill = sex)) +
  geom_boxplot() +
  labs(title = "Avg Vessel Distance by Super Ager Status and Sex",
       x = "Super Ager Status",
       y = "Average Vessel Distance") +
  theme_minimal()

# Association with Brain Variables: Volume (vol_wHC_bi)
merged_data_vol <- merged_data[!is.na(merged_data$vol_wHC_bi), ]
cor_vol <- cor( merged_data_vol$vol_wHC_bi,merged_data_vol$avg_vd, use = 'complete.obs') #0.2779

# Linear model
model_vol <- lm(merged_data_vol$vol_wHC_bi  ~ merged_data_vol$avg_vd + merged_data_vol$age, data= merged_data_vol)
summary(model_vol)

# Plot Volume vs Average Vessel Distance
ggplot(merged_data_vol, aes(x = avg_vd, y = vol_wHC_bi)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = " Volume vs Average Vessel Distance ",
       x = "Average Vessel Distance",
       y = "Volume") +
  theme_minimal()


# Association with Pathology: ABRatio, pTau217, AT_term, MTLROI_DVR
cor(merged_data$ABratio, merged_data$avg_vd,use = 'complete.obs') 
plot(merged_data$ABratio, merged_data$avg_vd, main = " ABratio vs Avg Vessel Distance", xlab = "ABratio", ylab = "Avg Vessel Distance")

cor(merged_data$pTau217, merged_data$avg_vd,use = 'complete.obs') 
plot(merged_data$pTau217, merged_data$avg_vd,main = "pTau217 vs Avg Vessel Distance", xlab = "pTau217", ylab = "Avg Vessel Distance")

cor(merged_data$AT_term, merged_data$avg_vd,use = 'complete.obs') 
plot(merged_data$AT_term, merged_data$avg_vd,main = "AT_term vs Avg Vessel Distance", xlab = "AT_term", ylab = "Avg Vessel Distance")

cor(merged_data$MTLROI_DVR, merged_data$avg_vd,use = 'complete.obs') 
plot(merged_data$MTLROI_DVR, merged_data$avg_vd, main = "MTLROI_DVR vs Avg Vessel Distance", xlab = "MTLROI_DVR", ylab = "Avg Vessel Distance")

# Fitness association: VO2 max 
cor_fitness <- cor(merged_data$VO2_kg_max, merged_data$avg_vd,use = 'complete.obs') 
plot(merged_data$VO2_kg_max, merged_data$avg_vd, main = "Fitness vs Average Vessel Distane", xlab = "VO2_kg_max", ylab = "Avg Vessel Distance")

# Linear model for fitness
model_fitness <- lm(VO2_kg_max ~ avg_vd + age +sex + edu_yrs , data= merged_data)
summary(model_fitness)







