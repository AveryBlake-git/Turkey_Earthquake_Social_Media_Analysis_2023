.libPaths("D://software//R//packages")


# 加载所需的库
library(data.table)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)
library(topicmodels)
library(wordcloud)
library(readxl)
library(lubridate)
library(ggplot2)
library(dplyr)
library(tidyr)

# 读取合并后的数据文件
merged_data <- read_excel('D:/大学/课件资料/第六学期/保险精算智能/期末论文-舆情分析/english/merge.xls')

# 创建语料库
texts <- corpus(merged_data$Tweet)

# 文本预处理
toks <- tokens(texts, what = 'word', 
               remove_punct = TRUE, remove_symbols = TRUE, 
               remove_numbers = TRUE, remove_url = TRUE)
toks <- tokens_tolower(toks)
toks <- tokens_remove(toks, stopwords('english'))
toks <- tokens_wordstem(toks)
# 移除非字母字符
toks <- tokens_replace(toks, pattern = "[^a-z]", replacement = "", valuetype = "regex")

# 创建文档-词项矩阵
dtm <- dfm(toks)
voc_docfreq <- docfreq(dtm)
dtm <- dtm[, voc_docfreq >= 10]

# 计算词频
word_freq <- textstat_frequency(dtm)
print(head(word_freq, 20))

# 应用LDA主题模型
dtm.lda <- convert(dtm, to = "topicmodels")
lda.model <- LDA(dtm.lda, k = 5, method = "Gibbs", 
                 control = list(seed = 123, burnin = 2000, iter = 2000, keep = 200))

# 查看主题
top_terms <- terms(lda.model, 10)
print(top_terms)

# 计算困惑度
perplexity_value <- perplexity(lda.model, newdata = dtm.lda)
print(paste("Perplexity:", perplexity_value))

# 提取并可视化LDA结果
terms <- as.matrix(terms(lda.model, 20))
beta <- posterior(lda.model)$terms

# 为每个主题绘制词云
par(mfrow=c(2,3))
for (i in 1:ncol(terms)){
  term.probs <- beta[i, terms[,i]]
  wordcloud(words = terms[,i], freq = term.probs*100, min.freq = 1,
            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
            main = paste("Topic", i))
}

# 结合评论的情感倾向，比较好评和差评的关键词
# 注意：这里的分类方法可能更多地反映了热点词汇分布，而非真正的情感倾向
target <- ifelse(merged_data$likeCount >= 10, 'positive', 'negative')
dtm.group <- dfm_group(dtm, groups = target)
keyness_res <- textstat_keyness(dtm.group, target = 'positive')
textplot_keyness(keyness_res)



#=============================情感分析=============================================
library(syuzhet)

# 进行情感分析
sentiment_scores <- get_sentiment(merged_data$Tweet, method="syuzhet")

# 添加情感分数到数据框
merged_data$sentiment <- sentiment_scores

# 计算每天的平均情感分数
daily_sentiment <- merged_data %>%
  group_by(date) %>%
  summarise(avg_sentiment = mean(sentiment))

# 绘制情感随时间的变化
daily_sentiment$date <- as.Date(daily_sentiment$Date)

ggplot(daily_sentiment, aes(x = date, y = avg_sentiment)) +
  geom_line() +
  geom_smooth(method = "loess") +
  labs(title = "Average Sentiment Over Time", x = "Date", y = "Average Sentiment") +
  theme_minimal()
















