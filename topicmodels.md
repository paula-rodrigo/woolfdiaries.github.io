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
<p><code>
<br>install.packages('tidyverse')</br>
<br>install.packages('tidytext')</br>
<br>library(tidyverse)</br>
<br>library(tidytext)</br>
<br>cb  <- read_csv("vw-diaries.csv")</br>
<br>#put the data into a tibble (data structure for tidytext)</br>
<br>#telling R what kind of data is in the 'text',</br>
<br>#'line', and 'data' columns in our original csv.</br>
<br>#stripping out all the digits from the text column</br>
<br>cb_df <- tibble(id = cb$line, text = (str_remove_all(cb$text, "[0-9]")), date = cb$date, year = cb$year)</br>
<br>#turn cb_df into tidy format</br>
<br>tidy_cb <- cb_df %>%
  unnest_tokens(word, text)</br>
<br>data(stop_words)</br>
<br>#delete stopwords from our data</br>
<br>tidy_cb <- tidy_cb %>%
  anti_join(stop_words)</br>
<br>#transform list into matrix</br>
<br>cb_words <- tidy_cb %>%
  count(id, word, sort = TRUE)</br>
<br>head(cb_words)</br>
<br>dtm <- cb_words %>%
  cast_dtm(id, word, n)</br>
<br>require(topicmodels)</br>
<br>#number of topics</br>
<br>K <- 8</br>
<br>#set random number generator seed</br>
<br>#for purposes of reproducibility</br>
<br>set.seed(9161)</br>
<br>#compute the LDA model, inference via 1000 iterations of Gibbs sampling</br>
<br>topicModel <- LDA(dtm, K, method="Gibbs", control=list(iter = 500, verbose = 25))</br>
<br>#look the results (posterior distributions)</br>
<br>tmResult <- posterior(topicModel)</br>
<br>#format of the resulting object</br>
<br>attributes(tmResult)</br>
<br>#lengthOfVocab</br>
<br>ncol(dtm)</br>
<br>#topics are probability distributions over the entire vocabulary</br>
<br>beta <- tmResult$terms   # get beta from results</br>
<br>dim(beta)</br>
<br>#probability distribution of each document's contained topics</br>
<br>theta <- tmResult$topics</br>
<br>dim(theta)  </br>
<br>top5termsPerTopic <- terms(topicModel, 5)</br>
<br>topicNames <- apply(top5termsPerTopic, 2, paste, collapse=" ")</br>
<br>topicNames</br>
<br>#visualization</br>
<br>library("reshape2")</br>
<br>library("ggplot2")</br>
<br>#select some documents for the purposes of sample visualizations</br>
<br>exampleIds <- c(2, 20, 40)</br>
<br>N <- length(exampleIds)</br>
<br>topicProportionExamples <- theta[exampleIds,]</br>
<br>colnames(topicProportionExamples) <- topicNames</br>
<br>vizDataFrame <- melt(cbind(data.frame(topicProportionExamples), document = factor(1:N)), variable.name = "topic", id.vars = "document")  </br>
<br>ggplot(data = vizDataFrame, aes(topic, value, fill = document), ylab = "proportion") +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +  
  coord_flip() +
  facet_wrap(~ document, ncol = N)</br>
<br>#topics over time</br>
<br>#append decade information for aggregation</br>
<br>cb$decade <- paste0(substr(cb$date, 0, 3), "0")</br>
<br>#get mean topic proportions per year</br>
<br>topic_proportion_per_year <- aggregate(theta, by = list(year = cb$year), mean)</br>
<br>#set topic names to aggregated columns</br>
<br>colnames(topic_proportion_per_year)[2:(K+1)] <- topicNames</br>
<br>#reshape data frame, for when I get the topics over time thing sorted</br>
<br>vizDataFrame <- melt(topic_proportion_per_year, id.vars = "year")</br>
<br>#plot topic proportions per deacde as bar plot</br>
<br>require(pals)</br>
<br>ggplot(vizDataFrame, aes(x=year, y=value, fill=variable)) +
  geom_bar(stat = "identity") + ylab("proportion") +
  scale_fill_manual(values = paste0(alphabet(20), "FF"), name = "year") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))</br>
</code></p>
  
---

click [here](https://github.com/paula-rodrigo/week-six/tree/master/vw-diaries-r) for all of the data and scripts that I used.
