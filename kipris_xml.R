library(xml2)
library(httr)
library(tidyverse)
library(progress)
library(glue)

# general search info page : https://plus.kipris.or.kr/portal/data/service/DBII_000000000000001/view.do?menuNo=200100&kppBCode=&kppMCode=&kppSCode=&subTab=SC001&entYn=N&clasKeyword=#soap_ADI_0000000000002130
auth_key <- "1fCRg1mSN=fYyE8OQdfhC6MZxEnDsjDmPsSbsPi0T=s="
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/"

# General Search keyword
search_keyword <- "TP53"
numRows <- 200
register_number_list <- list()

# General Search extraction
general_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0&ServiceKey=",auth_key)
xml_node <- httr::GET(general_search) %>% httr::content(encoding = "UTF-8") # raw node

responese_value <- xml_node %>% xml_find_all(".//successYN") %>% xml_text() # Y or N

if(responese_value != "Y"){}

total_count <- xml_node %>% xml_find_all(".//totalCount") %>% xml_text() %>% as.integer() # integer
total_page <- round(total_count / numRows) + 1 # total count

# each page search
# page 1 시작
for(page in seq(1,total_page)){
  page_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0", "&pageNo=", page, "&numOfRows=",numRows,"","&ServiceKey=", auth_key)
  all_xml_node <- httr::GET(page_search) %>% httr::content(encoding = "UTF-8")
  register_number_list[[page]] <- all_xml_node %>% xml_find_all(".//body") %>% xml_find_all(".//applicationNumber") %>% xml_text()
  Sys.sleep(2);print(paste0(page, " is done!@!"))
}

# register number
combine_register_number <- register_number_list %>% unlist()


# Bibliography extraction
biblio_search <- paste0(url, "getBibliographyDetailInfoSearch?applicationNumber=",combine_register_number[2],"&ServiceKey=", auth_key)

