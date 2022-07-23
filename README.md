# Twitter COVID-19 Sentiment Analysis

  ## Project Overview
This project seeks to identify any correlation between ∆ daily inoculation rates and ∆ twitter sentiment surrounding COVID-19. I chose the pandemic as my topic because of it's societal relevance and implications as an ongoing event.
      
  - Data Sources: [Twitter](https://www.trackmyhashtag.com/blog/free-twitter-datasets/) | [CDC](https://covid.cdc.gov/covid-data-tracker/#datatracker-home) | [Kaggle](https://www.kaggle.com/gpreda/all-covid19-vaccines-tweets)


- Collected more than 150,000 tweets related to COVID-19 and vaccines in multiple languages using the Twitter API and indexed on an AWS EC2 instance.
- Implemented the backend of a web application using Flask to enabling multi-keyword queries and designed filters and pagination to streamline the results to increase efficiency by 78%.
- Developed an API to facilitate search and support a dashboard for graphical representations of the entire corpus.


## Analysis
### Database
    Database Management System
- Extract CSV datasets from data sources (referenced above), transforming and cleaning them with Python, and loading the datasets using Amazon Web Services and PostgreSQL (server/database). This allows us to establish connection with the model, and store static data for use during the project.
- Constructed as an Amazon RDS instance to store transformed data.
<p>
   
    Machine Learning Model

Next, implementing a natural language processing algorithm allows us to gather sentiment analysis
- Machine Learning Libraries: pyspark, twitter api, textblob
- Description of preliminary data preprocessing
1. Load historical twitter covid vaccine data from kaggle. 
2. Clean tweets with clean_tweet function(regex), tokenize and get ready for text classification. Also, clean up function for removing hashtags, URL's, mentions, and retweets.
3. Apply Textblob.sentiment.polarity and Textblob.sentiment.subjectivity, ready for sentiment analysis.
4. Plot top 10 words from postivie and negative-resulted words. 

## Challenges and Limitations
    Problems
- Facebook, Instagram and TikTok were all considered initially, but did not have the necessary data readily available.
- Ran into issues with gaining Academic Twitter accounts to be able to access the Twitter API.
- After gaining access to tweets my original goal of using the location of tweets was not possible due to most tweets not having geotag data
- The Twitter API was very limited to the amount of data I could pull. Alternative dataset will be needed.
- Using academic accounts only allows access back to 7 days of tweets. I could not get twitter's full archive search without having a twitter scholar account. 
<p>
    
    Solutions
- I decided to use Twitter since it's API was available after submitting applications.
- Due to lack of geodata, I decided to switch to using twitter sentiment over time, rather than region
- I decided to use a Kaggle Dataset, which provided me with tweets from December 21, 2020. 