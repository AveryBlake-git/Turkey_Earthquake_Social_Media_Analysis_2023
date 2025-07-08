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
###从merged_data中提取Tweet列，并创建一个语料库对象。
texts <- corpus(merged_data$Tweet)

# 文本预处理
###清理和标准化文本数据，去除无用信息，以便于后续分析。
toks <- tokens(texts, what = 'word', 
               remove_punct = TRUE, remove_symbols = TRUE, 
               remove_numbers = TRUE, remove_url = TRUE)
toks <- tokens_tolower(toks)
toks <- tokens_remove(toks, stopwords('english'))
toks <- tokens_wordstem(toks)
# 移除非字母字符
toks <- tokens_replace(toks, pattern = "[^a-z]", replacement = "", valuetype = "regex")

# 创建文档-词项矩阵
###创建文档-词项矩阵，并只保留出现频率不少于10次的词。
dtm <- dfm(toks)
voc_docfreq <- docfreq(dtm)
dtm <- dtm[, voc_docfreq >= 10]

# 计算词频，并打印前20个高频词
word_freq <- textstat_frequency(dtm)
print(head(word_freq, 20))
###上边的方法让我们确定了字典；这个字典比我自己编词汇效果要好，困惑度大幅降低。

# 使用预定义的字典，查找文本是否包含特定主题
myDict <- dictionary(list(
  disaster_rescue = c('earthquak', 'help', 'rescue', 'victim', 'relief', 'survivor', 'support', 'injur'),
  society = c('peopl', 'communiti', 'public', 'resident', 'citizen'),
  media = c('news', 'report', 'media', 'broadcast', 'journalist'),
  organization = c('respond', 'reaction', 'organis', 'crisi', 'effort', 'coordin')
))

dtm.match <- as.matrix(dfm_lookup(dtm, myDict))
print(dtm.match[1:20, ])

# 应用主题模型，挖掘文本潜在信息
# LSA主题模型
###将文档-词项矩阵（DTM）转换为TF-IDF（词频-逆文档频率）加权矩阵。
dtm.weights <- dfm_tfidf(dtm)
###这一行使用加权后的TF-IDF矩阵进行潜在语义分析（LSA），提取三个潜在主题
lsa.mod <- textmodel_lsa(dtm.weights, nd = 3)
###这一行从LSA模型中提取词汇-主题矩阵。每个词汇在每个主题上的权重构成这个矩阵。
###这些权重表示某个词汇在特定主题中的重要性。
word_topic_matrix <- lsa.mod$features
###这一行将文档-主题矩阵进行转置。原始矩阵中每一行表示一个文档在各个主题上的权重，
###转置后每一列表示一个主题在各个文档中的权重。
topic_document_matrix <- t(lsa.mod$docs)
# 查看每个主题的特征词
###显示有两个主题，每个值代表该词汇在对应主题中的权重。
###权重越大，说明该词汇在该主题中的重要性越高
print(word_topic_matrix)


# LDA主题模型
dtm.lda <- convert(dtm, to = "topicmodels")
lda.model <- LDA(dtm.lda, k = 4, method = "Gibbs", 
                 control = list(seed = 123, burnin = 1000, iter = 1000, keep = 100))
perplexity(lda.model, newdata = dtm.lda)

# 提取并可视化LDA结果
###每个主题的前20个词。
terms <- as.matrix(terms(lda.model, 20))
beta <- posterior(lda.model)$terms
terms
beta
colnames(terms) <- as.character(1:ncol(terms))
# 删除第三列第一个空值，并将下方值向上移（不然总是报错）
terms[, 3] <- c(terms[-1, 3], NA)


# 为每个主题绘制词云
#par(mfrow=c(2,2))
#for (i in 1:ncol(terms)){
#  term.probs <- beta[i, terms[,i]]
#  wordcloud(words = terms[,i], freq = term.probs*100, min.freq = 1,
#            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
#            main = paste("Topic", i))
#}

##总是报错，我不循环了，为每个主题生成一个词云
par(mfrow=c(1,1))
# 对第一个主题生成词云图
i <- 1
current_terms <- terms[, i]
term_indices <- match(current_terms, colnames(beta))
valid_indices <- !is.na(term_indices)
current_terms <- current_terms[valid_indices]
term_indices <- term_indices[valid_indices]

if (length(term_indices) > 0) {
  term.probs <- beta[i, term_indices]
  wordcloud(words = current_terms, freq = term.probs * 100, min.freq = 1,
            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
            main = paste("Topic", i))
} else {
  cat("Topic", i, "没有找到有效的词汇。\n")
}
# 对第二个主题生成词云图
i <- 2
current_terms <- terms[, i]
term_indices <- match(current_terms, colnames(beta))
valid_indices <- !is.na(term_indices)
current_terms <- current_terms[valid_indices]
term_indices <- term_indices[valid_indices]

if (length(term_indices) > 0) {
  term.probs <- beta[i, term_indices]
  wordcloud(words = current_terms, freq = term.probs * 100, min.freq = 1,
            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
            main = paste("Topic", i))
} else {
  cat("Topic", i, "没有找到有效的词汇。\n")
}
# 对第三个主题生成词云图
i <- 3
current_terms <- terms[, i]
term_indices <- match(current_terms, colnames(beta))
valid_indices <- !is.na(term_indices)
current_terms <- current_terms[valid_indices]
term_indices <- term_indices[valid_indices]

if (length(term_indices) > 0) {
  term.probs <- beta[i, term_indices]
  wordcloud(words = current_terms, freq = term.probs * 100, min.freq = 1,
            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
            main = paste("Topic", i))
} else {
  cat("Topic", i, "没有找到有效的词汇。\n")
}
# 对第四个主题生成词云图
i <- 4
current_terms <- terms[, i]
term_indices <- match(current_terms, colnames(beta))
valid_indices <- !is.na(term_indices)
current_terms <- current_terms[valid_indices]
term_indices <- term_indices[valid_indices]

if (length(term_indices) > 0) {
  term.probs <- beta[i, term_indices]
  wordcloud(words = current_terms, freq = term.probs * 100, min.freq = 1,
            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
            main = paste("Topic", i))
} else {
  cat("Topic", i, "没有找到有效的词汇。\n")
}


head(t(topics(lda.model, k = 2)))
alpha <- posterior(lda.model)$topics
alpha

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
  group_by(Date) %>%
  summarise(avg_sentiment = mean(sentiment))

# 绘制情感随时间的变化
# 转换 Date 列为日期格式，并创建新的 date 列
daily_sentiment$date <- as.Date(daily_sentiment$Date)
ggplot(daily_sentiment, aes(x = date, y = avg_sentiment)) +
  geom_line() +
  geom_smooth(method = "loess") +
  labs(title = "Average Sentiment Over Time", x = "Date", y = "Average Sentiment") +
  theme_minimal()


#愤怒的情感
# 使用 NRC 方法进行情感分析
sentiment_scores_nrc <- get_nrc_sentiment(merged_data$Tweet)

# 添加情感分数到数据框
merged_data <- cbind(merged_data, sentiment_scores_nrc)

# 计算每天的平均情感分数
daily_sentiment_nrc <- merged_data %>%
  group_by(Date) %>%
  summarise(
    anger = mean(anger),
    anticipation = mean(anticipation),
    disgust = mean(disgust),
    fear = mean(fear),
    joy = mean(joy),
    sadness = mean(sadness),
    surprise = mean(surprise),
    trust = mean(trust),
    positive = mean(positive),
    negative = mean(negative)
  )

# 绘制情感随时间的变化 (例如，愤怒情感)
daily_sentiment_nrc$date <- as.Date(daily_sentiment_nrc$Date)
ggplot(daily_sentiment_nrc, aes(x = date, y = anger)) +
  geom_line() +
  geom_smooth(method = "loess") +
  labs(title = "Average Anger Sentiment Over Time (NRC)", x = "Date", y = "Average Anger Sentiment") +
  theme_minimal()

# 恐惧的情感
daily_sentiment_nrc$date <- as.Date(daily_sentiment_nrc$Date)
ggplot(daily_sentiment_nrc, aes(x = date, y = fear)) +
  geom_line() +
  geom_smooth(method = "loess") +
  labs(title = "Average Anger Sentiment Over Time (NRC)", x = "Date", y = "Average fear Sentiment") +
  theme_minimal()














