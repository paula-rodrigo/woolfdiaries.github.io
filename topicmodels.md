# [home](https://paula-rodrigo.github.io/woolfdiaries.github.io/)
---

After cleaning up my data and putting it into a csv file on Excel, I used Rstudio to create a topic model for the diary entries. I was especially interested in looking at the topics over time. In the visualizations below, you will see that Woolf did not write any diary entries in 1928. I am not entirely sure why, but it may be because she was working on another book, *Orlando: A Biography*, that year. By 1929, *To the Lighthouse* had been published and Woolf may have been reflecting back on it.

I experimented with different numbers of topics, starting from 15, then 20, then 5, then 8. I found that for the size of my corpus, 8 topics was the perfect amount to see a patern in the change of topics over time.
![8-topics](vw-topicsovertime-8.png)

Here we can see that she writes less about the lighthouse and about Vita as time goes on but more about Leonard and home life. The topics of writing and books also gradually lessens over time. ...

---
![15-topics](vw-topics-year.png)
<div>Topics over time, 15 topics.</div>

![20-topics](vw-topicsovertime-20.png)
<div>Topics over time, 20 topics.</div>

![5-topics](vw-5-topics.png)
<div>Topics over time, 5 topics.</div>

I found that 15 and 20 topics were too broad and cluttered to see any meaningful patterns while 5 topics was too narrow.

---
The code I used in R:

`install.packages('tidyverse')
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
K <- 8
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
cb$decade <- paste0(substr(cb$date, 0, 3), "0")
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
  theme(axis.text.x = element_text(angle = 90, hjust = 1))`
  
---

click [here](https://github.com/paula-rodrigo/week-six/tree/master/vw-diaries-r) for all of the data and scripts that I used.

---
# [home](https://paula-rodrigo.github.io/woolfdiaries.github.io/)
