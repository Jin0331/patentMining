library(xml2)
library(httr)
library(tidyverse)
library(glue)

# general search info page : https://plus.kipris.or.kr/portal/data/service/DBII_000000000000001/view.do?menuNo=200100&kppBCode=&kppMCode=&kppSCode=&subTab=SC001&entYn=N&clasKeyword=#soap_ADI_0000000000002130

auth_key <- "1fCRg1mSN=fYyE8OQdfhC6MZxEnDsjDmPsSbsPi0T=s="
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/"

# General Search keyword
search_keyword <- "TP53"
numRows <- 100

# General Search extraction
general_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0&ServiceKey=",auth_key)
xml_node <- httr::GET(general_search) %>% httr::content(encoding = "UTF-8") # raw node

total_count <- all_xml_node %>% xml_find_all(".//totalCount") %>% xml_text() %>% as.integer()
total_page <- round(total_count / numRows) + 1

# each page search
# page 1 시작
page_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0", "&pageNo=", page, "&numOfRows=",numRows,"","&ServiceKey=", auth_key)
all_xml_node <- httr::GET(page_search) %>% httr::content(encoding = "UTF-8")
register_number <- all_xml_node %>% xml_find_all(".//body") %>% xml_find_all(".//applicationNumber") %>% xml_text()


# Bibliography extraction
biblio_search <- paste0(url, "getBibliographyDetailInfoSearch?applicationNumber=",register_number,"&ServiceKey=", auth_key)

