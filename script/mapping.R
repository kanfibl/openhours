setwd('/Users/Alex/Dropbox/openingstijden/output')
df <- readRDS('total_out.rds')
maping <- readRDS('mapping_df.rds')
##convert factors into charachters
for(i in seq(ncol(df))){
  df[,i] <- as.character(df[,i])
}
for(i in seq(2)){
  maping[,i] <- as.character(maping[,i])
}

head(df)

#instance1
x<- unlist(strsplit(df[1,10],','))
x
#instance2
y <- unlist(strsplit(df[1,'sun'],','))
y
#map
for(i in seq_along(x)){
  match <- maping[maping$links %in% x[i],]$text
  if(!length(match) == 0L) {x[i] <- match}
}

#collapse
if(length(x)==4){
  x<- paste(paste(x[1:2],collapse = ''), paste(x[3:4],collapse = ''), sep = '-')
}
strsplit(df[1,10],',')


###FULL LOOP
#loop through each i column
for(i in (10:16)){
  #through each row and pick a cell, split it based on coma, then do the mapping and replacement
  for(row in seq(nrow(df))){
    x <- unlist(strsplit(df[row,i],','))
    for(j in seq_along(x)){
      match <- maping[maping$links %in% x[j],]$text
      if(!length(match) == 0L){
        x[j] <- match
      }
    }
    if(length(x)==4){
      x<- paste(paste(x[1:2],collapse = ''), paste(x[3:4],collapse = ''), sep = '-')
    }
    if(length(x)==8){
      x1 <- paste(paste(x[1:2],collapse = ''), paste(x[3:4],collapse = ''), sep = '-')
      x2 <- paste(paste(x[5:6],collapse = ''), paste(x[7:8],collapse = ''), sep = '-')
      x <- paste(x1,x2, sep='; ')
    }
    if(length(x)==12){
      x1 <- paste(paste(x[1:2],collapse = ''), paste(x[3:4],collapse = ''), sep = '-')
      x2 <- paste(paste(x[5:6],collapse = ''), paste(x[7:8],collapse = ''), sep = '-')
      x3 <- paste(paste(x[9:10],collapse = ''), paste(x[11:12],collapse = ''), sep = '-')
      x <- paste(x1,x2,x3, sep='; ')
    }
    df[row,i] <- x
  }
}
