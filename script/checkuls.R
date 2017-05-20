## GET LIST OBJECTS, DEAL a bunch of special cases: comment later
get_lis <- function(sesh, counter, case, x=1){
  result <- character()
  if (case==1) {
    if(counter==0){
      return(NA)
    }
    if(counter==1){
      css <- '#section-1 > div.right > ul > li'
      check <- sesh %>% html_node(css=css) %>% html_children() %>% html_name()
      if (check[1]=='br') {
        result <- sesh %>% html_nodes(css=css) %>% html_text() %>% gsub('\\t|\\r|\\n','')
        return(result)
      }
    }
    for(i in seq(counter)){
      css <- paste0('#section-1 > div.right > ul > li:nth-child(',i,') > h4')
      selector <- paste0('#section-1 > div.right > ul > li:nth-child(',i,') > span > img')
      day <- sesh %>% html_node(css = css) %>% html_text
      time <- sesh %>% html_nodes(css = selector) %>%
        html_attr(name ='src') %>% paste(collapse=',')
      if(time ==''){
        selector <- paste0('#section-1 > div.right > ul > li:nth-child(',i,') > span')
        time <- sesh %>% html_nodes(css = selector) %>%
          html_text()
      }
      links <- sesh %>% html_nodes(css = selector) %>%
        html_attr(name ='src')
      gifs <<- append(gifs, unlist(links))
      tmp <- paste(day, time, sep=': ')
      result <- append(result, tmp) %>% paste(collapse='; ')
    }
  return(result)
  }
  else {
    child <- paste0('ul:nth-child(',x*2,')')
    if(counter==0){
      return(NA)
    }
    if(counter==1){
      css <- paste0('#section-1 > div.right > ',child,' > li')
      check <- sesh %>% html_node(css=css) %>% html_children() %>% html_name()
      if (check[1]=='br') {
        result <- sesh %>% html_nodes(css=css) %>% html_text() %>% gsub('\\t|\\r|\\n','')
        return(result)
      }
    }
    result <- character()
    for(i in seq(counter)){
      css <- paste0('#section-1 > div.right > ',child,' > li:nth-child(',i,') > h4')
      selector <- paste0('#section-1 > div.right > ',child,' > li:nth-child(',i,') > span > img')
      day <- sesh %>% html_node(css = css) %>% html_text
      time <- sesh %>% html_nodes(css = selector) %>%
        html_attr(name ='src') %>% paste(collapse=',')
      if(time ==''){
        selector <- paste0('#section-1 > div.right > ul > li:nth-child(',i,') > span')
        time <- sesh %>% html_nodes(css = selector) %>%
          html_text()
      }
      links <- sesh %>% html_nodes(css = selector) %>%
        html_attr(name ='src')
      gifs <<- append(gifs, unlist(links))
      tmp <- paste(day, time, sep=': ')
      result <- append(result, tmp) %>% paste(collapse='; ')
    }
    return(result)
  }
}


#get the times based on which case we are in: comment later
checkuls <- function(sesh){
  count_ul <- sesh %>% html_nodes(css='#section-1 > div.right') %>%
    html_children() %>% html_name() %>% str_count('ul') %>% sum()
  if (count_ul==1) {
    case <- 1
    if ((sesh %>% html_nodes(css='#section-1 > div.right') %>%
      html_children() %>%
      html_name())[2] == 'p') {
        Koopavond <- NA
        count_li <- sesh %>% html_nodes(css='#section-1 > div.right > ul') %>%
          html_children() %>% length()
        Koopzondag <- get_lis(sesh, count_li,case=case)
        return(c(Koopavond,Koopzondag))
      } else if ((sesh %>% html_nodes(css='#section-1 > div.right') %>%
                    html_children() %>%
                    html_name())[4] == 'p') {
        Koopzondag <- NA
        count_li <- sesh %>% html_nodes(css='#section-1 > div.right > ul') %>%
          html_children() %>% length()
        Koopavond <- get_lis(sesh, count_li,case=case)
        return(c(Koopavond,Koopzondag))
      } else (stop('PROBLEM WITH P OBJECTS'))
} else if (count_ul==0) {
        Koopavond <- NA
        Koopzondag <- NA
        return(c(Koopavond,Koopzondag))
      } else if (count_ul==2){
        case <- 2
        count_li1 <- sesh %>%
          html_nodes(css='#section-1 > div.right > ul:nth-child(2)') %>%
          html_children() %>% length()
        count_li2 <- sesh %>%
          html_nodes(css='#section-1 > div.right > ul:nth-child(4)') %>%
          html_children() %>% length()
        Koopavond <- get_lis(sesh, count_li1,case=case,x=1)
        Koopzondag <- get_lis(sesh, count_li2,case=case,x=2)
        return(c(Koopavond,Koopzondag))
      }
}
