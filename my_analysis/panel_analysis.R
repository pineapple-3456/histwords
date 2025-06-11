library(tidyverse)
library(lmerTest)
library(showtext)
showtext_auto()

panel_data <- read.csv("my_analysis/panel_data.csv")

# 整理数据，宽表转长表，
# 对于每个词对，如果有任何一个年代相似度为0，就去除这一词对
# 标记为注释的行是对每个年代的所有相似度分别进行标准化
panel_data <- panel_data %>%
  filter_if(., is.numeric, all_vars(. != 0)) %>%
  #{ .[, paste0("X", "", seq(1950, 1990, 10))] <- scale(.[, paste0("X", "", seq(1950, 1990, 10))]); . } %>%
  pivot_longer(paste0("X", "", seq(1950, 1990, 10)), names_to = "decade", values_to = "similarity")

# 绘图
plot_1 <- ggplot(panel_data, aes(decade, similarity, col = attribute)) +
  geom_point(position = position_jitterdodge(0.15), size = 1, alpha = 0.4) +
  #stat_summary(fun = "mean", geom = "point", position = position_dodge(0.1), size = 1) +
  #stat_summary(fun.min = function(x) mean(x) + sd(x) / sqrt(length(x)),
  #             fun.max = function(x) mean(x) - sd(x) / sqrt(length(x)),
  #             #fun.min = function(x) mean(x) + sd(x), fun.max = function(x) mean(x) - sd(x),
  #             geom = "errorbar", width = 0.15,
  #             position = position_dodge(0.2)) +
  #stat_summary(aes(group = attribute), fun = "mean", geom = "line", position = position_dodge(0.2)) +
  geom_smooth(aes(group = attribute), method = "lm", se = TRUE, position = position_dodge(0.75)) +
  scale_color_manual("", values = c("#5066a1", "#e8743c"),
                     labels = c("道德-自我", "道德-他人")) +
  scale_x_discrete(labels = c("1950", "1960", "1970", "1980", "1990")) +
  theme_bw() +
  theme(legend.position = "top")

ggsave("my_analysis/interaction.pdf", width = 17, height = 15, units = "cm")

# 自变量编码，混合效应模型估计
panel_data$decade_code <- panel_data$decade
for (decade in seq(1950, 1990, 10)) {
  panel_data$decade_code <- replace(panel_data$decade_code,
                                    panel_data$decade_code == paste0("X", "", decade),
                                    (decade - 1950) / 10)
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

