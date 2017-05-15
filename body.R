setwd('/Users/Alex/Dropbox/openingstijden')

#libraries
lapply(list("dplyr", "rvest", "stringr", "xlsx", "readxl","seleniumPipes",
            "regexPipes", "gtools","readxl",'lubridate'), require, c = 1)
#functions to deal with special hours
source("checkuls.R")

#go to regions
first_sess <- html_session('https://www.openingstijden.nl/steden/')
#get names and links of regions
region_links <- first_sess %>% html_nodes(css ='#content > div.shoplocation-bar > div > div > a') %>% html_attr(name = 'href')
region_names <- first_sess %>% html_nodes(css ='#content > div.shoplocation-bar > div > div > a') %>% html_text()

#initialize df to which we append every row
df <- data.frame("StoreName"=character(),
                 "StoreKind"=character(),
                 "Region"=character(), 
                 "City"=character(),
                 "Street"=character(),
                 "postalcode"=character(),"locality"=character(), "phone"=character(), 
                 'week'=character(),
                 "mon"=character(),
                 "tue"=character(),
                 "wed"=character(),
                 "thu"=character(),
                 "fri"=character(),
                 "sat"=character(),
                 "sun"=character(),
                 "latehours"=character(),
                 "sundayhours"=character())

#save links with bad http requests
broken_links <- list()
#save gif links
gifs <- list()

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
  selector <- paste0('#times-0 > ul > li:nth-child(',day,') > div > span > img')
  result <- sesh %>% html_nodes(css = selector) %>% 
    html_attr(name ='src')
  if(length(result)==0) {
    selector <- paste0('#times-0 > ul > li:nth-child(',day,') > div > span')
    result <- sesh %>% html_nodes(css = selector) %>% 
      html_text()
    return(result)} else {
      gifs <<- append(gifs, unlist(result))
      return(result)
    }
} 


####BODY#########
#get names and links of cities in each region
for(i in seq(length(region_links))) { 
  print(paste0('loop level 1, cycle #', i))
  sesh <- check_sesh(paste0('https://www.openingstijden.nl/', region_names[i]))
  if (!is.null(sesh)) {
    cities_links <- sesh %>% html_nodes(css = '#results-static > li > ul > li > a') %>% html_attr(name = 'href')
    cities_names <- sesh %>% html_nodes(css = '#results-static > li > ul > li > a') %>% html_text()
    
    #get names and links of store kinds in each city
    for(j in seq(length(cities_links))){
      if(j==1)
      print(paste0('loop level 2, cycle #', j))
      sesh <- check_sesh(cities_links[j])
      if (!is.null(sesh)){
        chain_city_links <- sesh %>% 
          html_nodes(css = '#content > div.opensunday-bar > ul > li > ul > li > a') %>%
          html_attr(name = 'href')
        chain_city_names <- sesh %>% 
          html_nodes(css = '#content > div.opensunday-bar > ul > li > ul > li > a') %>%
          html_text() %>% gsub('\\t|\\r|\\n','')
        
        #get names and links of stores within category
        for(x in seq(length(chain_city_links))){
          print(paste0('loop level 3, cycle #', x))
          sesh <- check_sesh(chain_city_links[x])
          StoreKind <- chain_city_names[x]
          if (!is.null(sesh)){
            store_links <- sesh %>% html_nodes(css = '#results-ajax > ul > li > h3 > a') %>% 
              html_attr(name ='href')
            store_names <- sesh %>% html_nodes(css = '#results-ajax > ul > li > h3 > a') %>% 
              html_text %>% gsub('\\t|\\r|\\n','')
            for(y in seq(length(store_links))){
              print(paste0('loop level 4, cycle #', y))
              sesh <- check_sesh(store_links[y])
              if (!is.null(sesh)){
                
                #full store name from the widget on the right side of the page
                store_name <- sesh %>% html_node(css = '#sidebar > div.widget.info-widget > h1') %>% html_text()
                
                #get address data
                streetAddress <- sesh %>% 
                  html_node(xpath = '//*[@id="content"]/div/div/span[@itemprop="address"]/span[@itemprop="streetAddress"]') %>% 
                  html_text()
                postalCode <- sesh %>% 
                  html_node(xpath = '//*[@id="content"]/div/div/span[@itemprop="address"]/span[@itemprop="postalCode"]') %>% 
                  html_text()
                city <- sesh %>% 
                  html_node(xpath = '//*[@id="content"]/div/div/span[@itemprop="address"]/span[@itemprop="addressLocality"]') %>% 
                  html_text()
                phone <- sesh %>% 
                  html_node(xpath = '//*[@id="content"]/div/div/span[@itemprop="telephone"]') %>% 
                  html_text()
                #get regular times and week applicable
                x<-gettimes(2,sesh)
                whatweek <- sesh %>% html_node(css='#times-0 > h3 > span') %>% html_text()
                Monday <- paste(gettimes(2,sesh),collapse=',')
                Tuesday <- paste(gettimes(3,sesh),collapse=';')
                Wednesday <- paste(gettimes(4,sesh),collapse=';')
                Thursday <- paste(gettimes(5,sesh),collapse=';')
                Friday <- paste(gettimes(6,sesh),collapse=';')
                Saturday <- paste(gettimes(7,sesh),collapse=';')
                Sunday <- paste(gettimes(8,sesh),collapse=';')
                
                #deal with special times, lots of special cases in the relevant file chekuls.R
                lateshop <- checkuls(sesh)[1]
                sundayshop <- checkuls(sesh)[2]
                
                df_tmp <- data.frame("StoreName"=store_name,
                                     "StoreKind"=StoreKind,
                                     "Region"=region_names[i], 
                                     "City"=cities_names[j], 
                                     "Street"=streetAddress,
                                     "postalcode"=postalCode,
                                     "locality"=city, 
                                     "phone"=phone,
                                     "week"=whatweek,
                                     "mon"=Monday,
                                     "tue"=Tuesday,
                                     "wed"=Wednesday,
                                     "thu"=Thursday,
                                     "fri"=Friday,
                                     "sat"=Saturday,
                                     "sun"=Sunday,
                                     "latehours"=lateshop,
                                     "sundayhours"=sundayshop)
                

###notifications about broken links                
                df <- rbind(df, df_tmp)
              } else {print(paste('problem with',store_links[y]))
                broken_links <- append(broken_links,store_links[y])
                next}
            }
          } else {print(paste('problem with',chain_city_links[x]))
            broken_links <- append(broken_links,chain_city_links[x])
            next}
        }
      } else {print(paste('problem with',cities_links[j]))
        broken_links <- append(broken_links,cities_links[j])
        next}
    }
  } else {print(paste('problem with',region_links[i]))
    broken_links <- append(broken_links,region_links[i])
    next}
}
####END OF BODY

#save images
for(i in seq_along(gifs)){
  name <- paste0('images/',i,'.gif')
  download.file(unlist(unique(gifs))[i], name)
}

