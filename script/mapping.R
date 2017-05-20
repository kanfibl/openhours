setwd('/Users/Alex/Dropbox/openingstijden/output')
df <- readRDS('Drenthe.rds')
maping <- readRDS('../mapping_df.rds')
##convert factors into charachters
nacounter=0
for(i in seq(ncol(df))){
  df[,i] <- as.character(df[,i])
}
for(i in seq(2)){
  maping[,i] <- as.character(maping[,i])
}
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
    } else
    if(length(x)==8){
      x1 <- paste(paste(x[1:2],collapse = ''), paste(x[3:4],collapse = ''), sep = '-')
      x2 <- paste(paste(x[5:6],collapse = ''), paste(x[7:8],collapse = ''), sep = '-')
      x <- paste(x1,x2, sep='; ')
    } else
    if(length(x)==12){
      x1 <- paste(paste(x[1:2],collapse = ''), paste(x[3:4],collapse = ''), sep = '-')
      x2 <- paste(paste(x[5:6],collapse = ''), paste(x[7:8],collapse = ''), sep = '-')
      x3 <- paste(paste(x[9:10],collapse = ''), paste(x[11:12],collapse = ''), sep = '-')
      x <- paste(x1,x2,x3, sep='; ')
    } else
    if (length(x)==0){
      nacounter =+ 1
      print(paste('data missing, row: ',row, 'column:', i))
      x<- NA} else {
        print(x)
        print(paste('DOUBLE CHECK ROW ',row,'column ',i))
      }
    df[row,i] <- x
  }
}

###format special hours
#times-0 > ul > li:nth-child(2) > div > span:nth-child(1) > img:nth-child(1)
reformat_time <- function(x){
  
  if (grepl(x,'https')){
  result<- list()
  x<- gsub(x, ': ', '*: ')
  y<- unlist(strsplit(x,';'))
  for(i in seq_along(y)){
    z <- unlist((strsplit(y[i],'*: '))) 
    g <- unlist((strsplit(z[2], ','))) 
    for(j in seq_along(g)){
      match <- maping[maping$links %in% g[j],]$text
      if(!length(match) == 0L){
        g[j] <- match
      }}
    if(length(g)==4){
    g<- paste(paste(g[1:2],collapse = ''), paste(g[3:4],collapse = ''), sep = '-')}
    else if(length(g)==8){
      g1<- paste(paste(g[1:2],collapse = ''), paste(g[3:4],collapse = ''), sep = '-')
      g2<- paste(paste(g[5:6],collapse = ''), paste(g[7:8],collapse = ''), sep = '-')
      g <- paste(g1,g2, sep='; ')}
    else if(length(g)==12){
      g1<- paste(paste(g[1:2],collapse = ''), paste(g[3:4],collapse = ''), sep = '-')
      g2<- paste(paste(g[5:6],collapse = ''), paste(g[7:8],collapse = ''), sep = '-')
      g3<- paste(paste(g[9:10],collapse = ''), paste(g[11:12],collapse = ''), sep = '-')
      g <- paste(g1,g2,g3, sep='; ')}
    else if(is.na(g)){
        g<-'tot'
      } else {
        print(x)
        print(y)
        print(z)
        print(g)
        print('STOP')}
    tmp <- paste(z[1], g,sep=': ')
    result<-append(result, tmp)
  }
  result <- paste(result, collapse =';') %>% gsub('\\*','')
  return(result)
  } else if(grepl(x,"([0-9][A-Z])")) {
    result<-list()
    test<- str_locate_all(x, "([0-9][A-Z])")
    for(i in seq(nrow(test[[1]]))){
      if(i==1){m1<-substr(x, 0, test[[1]][i,1])} else {m1<-substr(x, test[[1]][i-1,2],
                                                                  test[[1]][i,1])}
      if (i<nrow(test[[1]])){m2<-substr(x, test[[1]][i,2], test[[1]][i+1,1])}
      else {m2<-substr(x, test[[1]][i,2], nchar(x))}
      result <- append(result,c(m1,m2))
    }
    result <- paste(result, collapse = '; ')
    return(result)
  } else if(grepl(x, '[: ]$')){
    x <- str_split(x, '; ')
    x<- map(x, function(l){
      l<- paste0(l, 'tot')})
    x<- x %>% unlist() %>% paste(collapse='; ')
    print(x)
    return(x)}
  else return(x)
}

for(i in (17:18)){
  for(row in seq(nrow(df))){
    x <- df[row, i]
    x<- reformat_time(x)
    if(length(x)==0){
      x<-NA}
    if(grepl(x,'NA: ; NA: ')) {
      print(paste('data missing, row: ',row, 'column:', i))
      }
    df[row,i] <- x
  }
}
