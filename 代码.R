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

# 创建文档-词项矩阵
dtm <- dfm(toks)
voc_docfreq <- docfreq(dtm)
dtm <- dtm[, voc_docfreq >= 10]

# 使用预定义的字典，查找文本是否包含特定主题
myDict <- dictionary(list(
  earthquake = c('earthquake', 'quake', 'tremor', 'seism*'),
  damage = c('damage', 'destruction', 'collapse', 'ruin*', 'wreck*'),
  rescue = c('rescue', 'survivor', 'aid', 'help', 'support', 'save*', 'assistance'),
  response = c('response', 'reaction', 'emergency', 'crisis', 'relief', 'evacu*')
))
dtm.match <- as.matrix(dfm_lookup(dtm, myDict))
dtm.match[1:20, ]

# 应用主题模型，挖掘文本潜在信息
# LSA主题模型
dtm.weights <- dfm_tfidf(dtm)
lsa.mod <- textmodel_lsa(dtm.weights, nd = 3)
word_topic_matrix <- lsa.mod$features
topic_document_matrix <- t(lsa.mod$docs)

# LDA主题模型
dtm.lda <- convert(dtm, to = "topicmodels")
lda.model <- LDA(dtm.lda, k = 5, method = "Gibbs", 
                 control = list(seed = 123, burnin = 1000, iter = 1000, keep = 100))
perplexity(lda.model, newdata = dtm.lda)

# 提取并可视化LDA结果
terms <- as.matrix(terms(lda.model, 20))
beta <- posterior(lda.model)$terms
terms
beta

# 为每个主题绘制词云
for (i in 1:ncol(terms)){
  term.probs <- beta[i, terms[,i]]
  wordcloud(words = terms[,i], freq = term.probs*100, min.freq = 1,
            colors = brewer.pal(8, "Dark2"), random.order = FALSE,
            main = paste("Topic", i))
}

head(t(topics(lda.model, k = 2)))
alpha <- posterior(lda.model)$topics
alpha

# 结合评论的情感倾向，比较好评和差评的关键词
target <- ifelse(merged_data$likeCount >= 10, 'positive', 'negative')
dtm.group <- dfm_group(dtm, groups = target)
keyness_res <- textstat_keyness(dtm.group, target = 'positive')
textplot_keyness(keyness_res)
