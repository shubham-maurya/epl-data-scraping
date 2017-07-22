# epl-data-scraping
This file contains the details of how I scraped a football dataset, from TransferMrkt.com and Fantasy Premier League.
Packages used - 
- Tidyverse
- RSelenium
- Rvest
- stringr

Needed to use RSelenium to scrape data from fantasy premier league, which was a dynamic website. Used rvest for Transfermrkt.com as it was static. 

Ultimately created a dataframe with the following attributes, for 461 players of the 2016-17 -
- name
- club
- age
- position
- page views (average number of daily Wikipedia searches from September 1, 2016 to May 1, 2017.
- FPL value
- FPL selection percent
- FPL points
- nationality

Will keep adding when needed for future projects.
