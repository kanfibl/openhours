#before passing the session that link works.
check_sesh <- function(link){
  tryCatch(html_session(link),
           warning=function(w){
             return(NULL)},
           error=function(e){
             return(NULL)})
}

#get regular times function
gettimes <- function(day,sesh){
  selector <- paste0('#times-0.times-1 > ul > li:nth-child(',day,') > div > span > img')
  result <- sesh %>% html_nodes(css = selector) %>%
    html_attr(name ='src')
  if(length(result)==0) {
    selector <- paste0('#times-0.times-1 > ul > li:nth-child(',day,') > div > span')
    result <- sesh %>% html_nodes(css = selector) %>%
      html_text()
    return(result)} else {
      gifs <<- append(gifs, unlist(result))
      return(result)
    }
}
