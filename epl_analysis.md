An Analysis of the English Premier League - Players and Teams 2016/2017
================

Exploring the Dataset
=====================

This dataset contains information for 461 players of the English Premier League, participating in 2016/17. This is still incomplete, as the transfer window is open. The data was scraped from TransferMrkt.com and Fantasy Premier League predominantly. To see the scraping, click [here](https://github.com/shubham-maurya/epl-data-scraping)

The head of the data looks like this -

``` r
head(df)
```

    ##                name    club age position position_cat market_value
    ## 1    Alexis Sanchez Arsenal  28       LW            1           65
    ## 2        Mesut Ozil Arsenal  28       AM            1           50
    ## 3         Petr Cech Arsenal  35       GK            4            7
    ## 4      Theo Walcott Arsenal  28       RW            1           20
    ## 5 Laurent Koscielny Arsenal  31       CB            3           22
    ## 6   Hector Bellerin Arsenal  22       RB            3           30
    ##   page_views fpl_value fpl_sel fpl_points region    nationality
    ## 1       4329      12.0  17.10%        264      3          Chile
    ## 2       4395       9.5   5.60%        167      2        Germany
    ## 3       1529       5.5   5.90%        134      2 Czech Republic
    ## 4       2393       7.5   1.50%        122      1        England
    ## 5        912       6.0   0.70%        121      2         France
    ## 6       1675       6.0  13.70%        119      2          Spain
    ##   new_foreign age_cat club_id big_club
    ## 1           0       4       1        1
    ## 2           0       4       1        1
    ## 3           0       6       1        1
    ## 4           0       4       1        1
    ## 5           0       4       1        1
    ## 6           0       2       1        1

This is an R Markdown format used for publishing markdown documents to GitHub. When you click the **Knit** button all R code chunks are run and a markdown file (.md) suitable for publishing to GitHub is generated.

Including Code
--------------

You can include R code in the document as follows:

``` r
summary(cars)
```

    ##      speed           dist       
    ##  Min.   : 4.0   Min.   :  2.00  
    ##  1st Qu.:12.0   1st Qu.: 26.00  
    ##  Median :15.0   Median : 36.00  
    ##  Mean   :15.4   Mean   : 42.98  
    ##  3rd Qu.:19.0   3rd Qu.: 56.00  
    ##  Max.   :25.0   Max.   :120.00

Including Plots
---------------

You can also embed plots, for example:

![](epl_analysis_files/figure-markdown_github-ascii_identifiers/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
