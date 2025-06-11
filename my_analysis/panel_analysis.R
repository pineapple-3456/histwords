library(tidyverse)
library(lmerTest)
library(nlme)

panel_data <- read.csv("my_analysis/panel_data.csv")

# 整理数据，宽表转长表，
# 对于每个词对，如果有任何一个年代相似度为0，就去除这一词对
# 标记为注释的行是对每个年代的所有相似度分别进行标准化
panel_data <- panel_data %>%
  filter_if(., is.numeric, all_vars(. != 0)) %>%
  #{ .[, paste0("X", "", seq(1950, 1990, 10))] <- scale(.[, paste0("X", "", seq(1950, 1990, 10))]); . } %>%
  pivot_longer(paste0("X", "", seq(1950, 1990, 10)), names_to = "decade", values_to = "similarity")

# 绘图，误差棒是标准误，
# 标记为注释的两行分别是把误差棒改成标准差，和把回归直线改为连线
ggplot(panel_data, aes(decade, similarity, col = attribute)) +
  stat_summary(fun = "mean", geom = "point", position = position_dodge(0.2)) +
  stat_summary(fun.min = function(x) mean(x) + sd(x) / sqrt(length(x)), fun.max = function(x) mean(x) - sd(x) / sqrt(length(x)),
               #fun.min = function(x) mean(x) + sd(x), fun.max = function(x) mean(x) - sd(x),
               geom = "errorbar", width = 0.2,
               position = position_dodge(0.2)) +
  #stat_summary(aes(group = attribute), fun = "mean", geom = "line", position = position_dodge(0.2)) +
  geom_smooth(aes(group = attribute), method = "lm", se = FALSE) +
  theme_bw()

# 自变量编码，混合效应模型估计
panel_data$decade_code <- panel_data$decade
for (decade in seq(1950, 1990, 10)) {
  panel_data$decade_code <- replace(panel_data$decade_code, panel_data$decade_code == paste0("X", "", decade), (decade - 1950) / 10)
}
panel_data$decade_code <- as.numeric(panel_data$decade_code)
panel_data$attribute_code <- relevel(factor(panel_data$attribute), ref = "attribute_1")

model <- lmer(similarity ~ attribute_code * decade_code + (1 | word_pair), data = panel_data)
HLM_summary(model)

#计算各个年代SC-WEAT效应量
for (decade in paste0("X", "", seq(1950, 1990, 10))) {
  data <- panel_data[panel_data$decade == decade,]

  diff <- data %>%
    group_by(attribute) %>%
    summarise(mean(similarity)) %>%
  { . <- .[2, "mean(similarity)"] - .[1, "mean(similarity)"]; . }

  d <- as.numeric(diff / sd(data$similarity))

  print(d)
}

