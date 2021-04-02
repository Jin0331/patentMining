library(xml2)
library(httr)
library(tidyverse)
library(glue)

auth_key <- "1fCRg1mSN=fYyE8OQdfhC6MZxEnDsjDmPsSbsPi0T=s="
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/"
search_keyword <- "TP53"
numRows <- "10"

# registerNumber extraction
general_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0&ServiceKey=",auth_key)
all_xml_node <- httr::GET(general_search) %>% httr::content(encoding = "UTF-8")

total_count <- all_xml_node %>% xml_find_all(".//totalCount") %>% xml_text() %>% as.integer()

register_number <- all_xml_node %>% xml_find_all(".//body") %>% xml_find_first(".//applicationNumber") %>% xml_text()

# Bibliography extraction

biblio_search <- paste0(url, "getBibliographyDetailInfoSearch?applicationNumber=",register_number,"&ServiceKey=", auth_key)

