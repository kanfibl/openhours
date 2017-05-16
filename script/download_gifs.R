#save images
for(i in seq_along(gifs)){
name <- paste0('images/',i,'.gif')
download.file(unlist(unique(gifs))[i], name)
}

}
