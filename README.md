# openhours
https://www.openingstijden.nl scraper.

* **/script** - contains the body and helper files
* **/gif_links** - rds objects with gif links from each region
* **/broken_links** - rds objects with broken links from each region
* **/output** - rds objects with dframes of output for each region
* **do_scrape.R** - launching function
* **region_links.rds** - 12 links to regions, serves as input.

# TO DO (KARO HELP! :D :D)

1. **commands.sh** - shell script looping from 1 to 12 and passing the trailing argument to do_scrape.R, similar to wozwaardeloket script. **Now do_scrape.R is passed n=1 for the first region**

2. post-process gif images and reassign opening times in the output data frames
