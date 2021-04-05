library(xml2)
library(httr)
library(tidyverse)

# general search info page : https://plus.kipris.or.kr/portal/data/service/DBII_000000000000001/view.do?menuNo=200100&kppBCode=&kppMCode=&kppSCode=&subTab=SC001&entYn=N&clasKeyword=#soap_ADI_0000000000002130
# forien https://plus.kipris.or.kr/portal/data/service/DBII_000000000000036/view.do?pageIndex=5&menuNo=200100&kppBCode=&kppMCode=&kppSCode=&subTab=SC001&entYn=N&clasKeyword=#soap_ADI_0000000000001507
auth_key <- "1fCRg1mSN=fYyE8OQdfhC6MZxEnDsjDmPsSbsPi0T=s="
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/"

# General Search keyword
# search_keyword <- "TP53"
# function
getPublishNumber <- function(search_keyword, numRows, auth_key){
  numRows <- 200
  register_number_list <- list()
  
  # General Search extraction
  general_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0&ServiceKey=",auth_key)
  xml_node <- httr::GET(general_search) %>% httr::content(encoding = "UTF-8") # raw node
  
  responese_value <- xml_node %>% xml_find_all(".//successYN") %>% xml_text() # Y or N
  
  if(responese_value == "N"){
    print("Not response")
    next
  } 
  
  total_count <- xml_node %>% xml_find_all(".//totalCount") %>% xml_text() %>% as.integer() # integer
  total_page <- round(total_count / numRows) + 1 # total count
  
  # each page search
  # page 1 시작
  page <- 1
  while(page <= total_page){
    page_search <- paste0(url, "getWordSearch?word=",search_keyword,"&year=0", "&pageNo=", page, "&numOfRows=",numRows,"","&ServiceKey=", auth_key)
    
    re <- FALSE
    tryCatch(
      expr = {
        all_xml_node <- httr::GET(page_search) %>% httr::content(encoding = "UTF-8")
      },
      error = function(e) { print(e);re <<- TRUE}
    )
    
    if(re){
      print("repose error!! reload!")
      next
    }
    
    register_number_list[[page]] <- all_xml_node %>% xml_find_all(".//body") %>% xml_find_all(".//applicationNumber") %>% xml_text()
    Sys.sleep(2);print(paste0(page, " page is done!@!"))
    page <- page + 1
  }
  
  # register number
  combine_register_number <- register_number_list %>% unlist()
  return(combine_register_number)
} # domestic search
getBibliography <- function(register_number, auth_key){
  biblio_search <- paste0(url, "getBibliographyDetailInfoSearch?applicationNumber=",register_number, "&ServiceKey=", auth_key)
  xml_node <- httr::GET(biblio_search) %>% httr::content(encoding = "UTF-8")
  
  # information extraction
  info_list <- list()
  {
    info_list[["invetionTitle"]] <- xml_node %>% xml_find_all(".//inventionTitle") %>% xml_text()
    info_list[["invetionTitle_eng"]] <- xml_node %>% xml_find_all(".//inventionTitleEng") %>% xml_text()
    info_list[["applicationNumber"]] <- xml_node %>% xml_find_all(".//applicationNumber") %>% xml_text()
    info_list[["applicationDate"]] <- xml_node %>% xml_find_all(".//applicationDate") %>% xml_text()
    info_list[["originalApplicationKind"]] <- xml_node %>% xml_find_all(".//originalApplicationKind") %>% xml_text()
    info_list[["familyApplicationNumber"]] <- xml_node %>% xml_find_all(".//familyApplicationNumber") %>% xml_text()
    info_list[["astrtCont"]] <- xml_node %>% xml_find_all(".//astrtCont") %>% xml_text()
    
    # claim
    info_list[["claimCount"]] <- xml_node %>% xml_find_all(".//claimCount") %>% xml_text()
    info_list[["claim"]] <- xml_node %>% xml_find_all(".//claimInfoArray") %>% xml_children() %>% xml_text() %>% 
      paste(collapse = "\n")
    
    # applicantinfo
    info_list[["eng"]] <-  xml_node %>% xml_find_all(".//applicantInfo//engName") %>% xml_text()
    info_list[["country"]] <- xml_node %>% xml_find_all(".//applicantInfo//country") %>% xml_text()
  }
  
  # character(0) to NA
  info_list_filter <- lapply(X = info_list, function(info){
    if(identical(info, character(0))){
      return(NA_character_)
    } else { return(info)}
  })
  
  biblio_DF <- tibble(country = "KOR", applicationNumber = info_list_filter[["applicationNumber"]], applicationDate = info_list_filter[["applicationDate"]], 
                      familyApplicationNumber = info_list_filter[["familyApplicationNumber"]], originalApplicationKind = info_list_filter[["originalApplicationKind"]],
                      invetionTitle = info_list_filter[["invetionTitle"]], invetionTitle_eng = info_list_filter[["invetionTitle_eng"]], 
                      claimCount = info_list_filter[["claimCount"]], claim = info_list_filter[["claim"]], inc = info_list_filter[["eng"]], 
                      inc_country = info_list_filter[["country"]])
  return(biblio_DF)
} # domestic search




# Bibliography extraction

register_number <- getPublishNumber(search_keyword = "TP53", numRows = 200, auth_key = auth_key)
biblio_DF <- getBibliography(register_number = register_number[5], auth_key = auth_key)
