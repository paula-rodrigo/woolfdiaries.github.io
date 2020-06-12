install.packages('tidyverse')
install.packages('tidytext')

library(tidyverse)
library(tidytext)

cb  <- read_csv("vw-diaries.csv")

# put the data into a tibble (data structure for tidytext)
# telling R what kind of data is in the 'text',
# 'line', and 'data' columns in our original csv.
# stripping out all the digits from the text column
cb_df <- tibble(id = cb$line, text = (str_remove_all(cb$text, "[0-9]")), date = cb$date, year = cb$year)

#turn cb_df into tidy format
tidy_cb <- cb_df %>%
  unnest_tokens(word, text)

data(stop_words)

# delete stopwords from our data
tidy_cb <- tidy_cb %>%
  anti_join(stop_words)

# transform list into matrix
cb_words <- tidy_cb %>%
  count(id, word, sort = TRUE)

head(cb_words)

dtm <- cb_words %>%
  cast_dtm(id, word, n)

require(topicmodels)
# number of topics
K <- 20
# set random number generator seed
# for purposes of reproducibility
set.seed(9161)
# compute the LDA model, inference via 1000 iterations of Gibbs sampling
topicModel <- LDA(dtm, K, method="Gibbs", control=list(iter = 500, verbose = 25))

# look the results (posterior distributions)
tmResult <- posterior(topicModel)

# format of the resulting object
attributes(tmResult)

# lengthOfVocab
ncol(dtm)

# topics are probability distributions over the entire vocabulary
beta <- tmResult$terms   # get beta from results
dim(beta)

# probability distribution of each document's contained topics
theta <- tmResult$topics
dim(theta)  

top5termsPerTopic <- terms(topicModel, 5)
topicNames <- apply(top5termsPerTopic, 2, paste, collapse=" ")
topicNames

#visualization
library("reshape2")
library("ggplot2")

# select some documents for the purposes of sample visualizations
exampleIds <- c(2, 20, 40)

N <- length(exampleIds)

topicProportionExamples <- theta[exampleIds,]
colnames(topicProportionExamples) <- topicNames

vizDataFrame <- melt(cbind(data.frame(topicProportionExamples), document = factor(1:N)), variable.name = "topic", id.vars = "document")  

ggplot(data = vizDataFrame, aes(topic, value, fill = document), ylab = "proportion") +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +  
  coord_flip() +
  facet_wrap(~ document, ncol = N)

#topics over time
# append decade information for aggregation
cb$year <- paste0(substr(cb$year, 0, 3), "0")
# get mean topic proportions per year
topic_proportion_per_year <- aggregate(theta, by = list(year = cb$year), mean)
# set topic names to aggregated columns
colnames(topic_proportion_per_year)[2:(K+1)] <- topicNames

# reshape data frame, for when I get the topics over time thing sorted
vizDataFrame <- melt(topic_proportion_per_year, id.vars = "year")

# plot topic proportions per deacde as bar plot
require(pals)
ggplot(vizDataFrame, aes(x=year, y=value, fill=variable)) +
  geom_bar(stat = "identity") + ylab("proportion") +
  scale_fill_manual(values = paste0(alphabet(20), "FF"), name = "year") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
