## do the scraping for this file
setwd('/Users/Alex/Dropbox/openingstijden')
region_links <- readRDS("region_links.rds")
#n = commandArgs(trailingOnly=TRUE)
source("script/exec_scrape.R")
for(n in seq(12)){
exec_scrape(region_links,n=n)
}
