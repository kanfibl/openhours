setwd('/Users/Alex/Dropbox/openingstijden/output')
files <- list.files()
df <- data_frame()
for(i in files){
  df<- rbind(df,readRDS(i))
}

saveRDS(df, 'total_out.rds')
setwd('/Users/Alex/Dropbox/openingstijden/gif_links')
files <- list.files()
gifs <- list()
for(i in files){
  gifs<- append(gifs, readRDS(i))
}

gifs <- unique(gifs)
saveRDS(gifs,'gif_links.rds')