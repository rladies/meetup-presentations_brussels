library(rvest)
library(dplyr)



# ---------
# WIKIPEDIA
# ---------


wiki_url <- "https://en.wikipedia.org/wiki/R_(programming_language)"

robotstxt::paths_allowed(wiki_url)

local_wiki <- read_html(wiki_url)

local_wiki %>% 
  html_nodes(css = ".wikitable") %>% 
  html_table()





# -----------
# DATACAMP
# -----------



#---------------
# sTEP 1 & 2
#---------------


url_DC <- "https://www.datacamp.com/courses/free-introduction-to-r"

robotstxt::paths_allowed(url_DC)

local_html_DC <- read_html(url_DC)


#---------------
# sTEP 3
#---------------


#selecting parts
local_html_DC %>% 
  html_nodes(css = "h4") 

local_html_DC %>% 
  html_nodes(css = ".chapter__title")

local_html_DC %>% 
  html_nodes(css = ".header-hero__stat") %>% html_attr(name = "class")



#---------------
# sTEP 4
#---------------

# parsing to R
local_html_DC %>% 
  html_nodes(css = ".header-hero__stat--participants") %>% 
  html_text() %>% 
  readr::parse_number()




#---------------
# GETTING MORE THAN ONE
#---------------


#course overview

course_overview_url <- "https://www.datacamp.com/courses/tech:r"

robotstxt::paths_allowed(course_overview_url)

local_copy <- read_html(course_overview_url)


local_copy %>% 
  html_nodes(css = "a")


all_course_links <- local_copy %>% 
  html_nodes(css = ".course-block > a") %>% 
  html_attr(name = "href")




# function to get participants

course_link <- all_course_links[1]


url <- httr::modify_url("https://www.datacamp.com", path = course_link)
local_copy <- read_html(url)
n_partic <- local_copy %>% 
  html_nodes(css = ".header-hero__stat--participants") %>% 
  html_text() %>% 
  readr::parse_number()

course_title <- stringr::str_remove(course_link, "/courses/")

df <- data.frame(date = Sys.Date(),
           course = course_title,
           participants <- n_partic,
           stringsAsFactors = FALSE)




#☺ build a function


get_participants <- function(course_link) {
  
  url <- httr::modify_url("https://www.datacamp.com", path = course_link)
  allowed <- robotstxt::paths_allowed(url)
  stopifnot(allowed == TRUE)
  
  local_copy <- read_html(url)
  n_partic <- local_copy %>% 
    html_nodes(css = ".header-hero__stat--participants") %>% 
    html_text() %>% 
    readr::parse_number()
  
  course_title <- stringr::str_remove(course_link, "/courses/")
  
  df <- data.frame(date = Sys.Date(),
                   course = course_title,
                   participants = n_partic,
                   stringsAsFactors = FALSE)
  Sys.sleep(1)
  
  df
  
}



#get 5 of them

get_participants(course_link)
purrr::map_df(all_course_links[1:5], get_participants)


