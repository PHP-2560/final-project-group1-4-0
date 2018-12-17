Our package will scrape US News university rankings, including the ranking, names, tuition, endowment, year founded, religious affiliation, amongst other aspects.

A dataframe with all US national universities (public and private) will be created, and some visualization (maps, plots, graphs, etc) will also be outputted. 

Since US News rankings change at least annually, this package can be utilized to scrape updated university information. Running the package will automatically scrape US News, create a data frame, and output all relevant plots with data frame information.
Specifically, the sentiment analysis utilizes Twitter (default to a sample of most recent Tweets) to output a value indicating positivity or negativity, a function calculates time to pay off student loans, and visualization functions utilize ggplot to output maps and descriptive data plots. 

In order for this package to work, all required packages listed below must be first installed:


[placeholder]

Each of us contributed the following:
Lucas: 
1. Sentiment analysis with Twitter's API (eg. given a word, how often and in what capacity does that word show up in the sample?)
2. Calculation of time to pay off student loans given a school's tuition, loan interest rate, and median starting salary
3. File layout

Kitty:
1. Scraping individual university pages
2. Organizing scraped data into a data frame
3. File layout

Charles:
1. Data cleaning for visualization
2. Visualization (maps, plots, graphs, etc)
3. File layout

William:
1. Data cleaning for visualization
2. Visualization (maps, plots, graphs, etc)
3. File layout
