# openhours
https://www.openingstijden.nl scraper.

**scrapes only main times**

# Order

1. do_scrape.R
2. then combineoutput.R
3. optional: download images
4. maping.R to format daytimes (read total_out.rds and mapping_df.rds )

# Content 

* **/script** - contains the body and helper files
* **/gif_links** - rds objects with gif links from each region
* **/broken_links** - rds objects with broken links from each region
* **/output** - rds objects with dframes of output for each region
* **do_scrape.R** - launching function
* **/script/combine.R** - combines output
* **region_links.rds** - 12 links to regions, serves as input.

# TO DO (KARO HELP! :D :D)

1. **commands.sh** - shell script looping from 1 to 12 and passing the trailing argument to do_scrape.R, similar to wozwaardeloket script. **Now do_scrape.R is passed n=1:12, so that it loops through and does one region after another** 
