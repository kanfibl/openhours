source("script/libraries.R")
source("script/functions.R")
source("script/checkuls.R")
exec_scrape <- function(RL, n) {
region_link <- RL[n]
broken_links <<- list()
gifs <<- list()
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

#save gif links

####BODY#########
#get names and links of cities in the region
region_name <<- gsub(region_link, 'https://www.openingstijden.nl/','') %>% sub('/','')
print(paste0('loop level 1, region ', region_name))
sesh <- check_sesh(region_link)
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
                                   "Region"=region_name,
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
              broken_links <<- append(broken_links,store_links[y])
              next}
          }
        } else {print(paste('problem with',chain_city_links[x]))
          broken_links <<- append(broken_links,chain_city_links[x])
          next}
      }
    } else {print(paste('problem with',cities_links[j]))
      broken_links <<- append(broken_links,cities_links[j])
      next}
  }
} else {print(paste('problem with',region_link))
  broken_links <<- append(broken_links,region_link)
  next}

saveRDS(df, paste0("output/",region_name,".rds"))
saveRDS(broken_links, paste0("broken_links/",n,".rds"))
saveRDS(gifs, paste0("gif_links/",n,".rds"))
print(paste0('Region ', region_name,' is scraped'))
}
