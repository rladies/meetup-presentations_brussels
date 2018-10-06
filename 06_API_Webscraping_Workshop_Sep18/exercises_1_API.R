# API exercises


# --------
# number 1
# --------



library(httr)


# url
url_ex1 <- "http://api.open-notify.org/iss-now.json"


# GET request
response <- GET(url_ex1)


#show content as json data
content <- content(response, as = "text")

#prettier
jsonlite::prettify(content)


#parsing json to R
content_jsonlite <- jsonlite::fromJSON(content)


#or much shorter - json format is autodetected and parsed
content_parsed <- content(response)



---
  
#------------
# API exercise 2
#------------


#Coordinates brussels
  
lat_bxl <- 50.85045
long_bxl <- 4.34878


#option 1: manual
url <- "http://api.open-notify.org/iss-pass.json?lat=50.85045&lon=4.34878"



#option 2: paste together
url <- paste0("http://api.open-notify.org/iss-pass.json?lat=", lat_bxl,
              "&lon=", long_bxl)


#option 3: build URL
url <- modify_url(url = "http://api.open-notify.org",
                  path = "iss-pass.json",
                  query = list(lat = lat_bxl, lon = long_bxl))


#GET request
response <- GET(url)

#alternative
GET(url = "http://api.open-notify.org/iss-pass.json", 
    query = list(lat = lat_bxl, lon = long_bxl))



#unpack response
content <- content(response)

#modify to R
pass_times <- data.frame(
  risetime = purrr::map_chr(content$response, "risetime"),
  duration = purrr::map_chr(content$response, "duration"))





#------------
# API exercise 3
#------------

# API: get all books

url <- "https://www.anapioficeandfire.com/api/books"
response_books <- GET(url)
content_books <- content(response_books)

#look into the book 
str(content_books, max.level = 2)



#find all book names
all_book_names <- purrr::map_chr(content_books, "name")




#find the info on all POV characters in book 1

content_book1 <- content_books[[1]]
str(content_book1, max.level = 1)

book1_pov <- content_book1$povCharacters
book1_pov <- unlist(book1_pov)



#call api for info on one character

url1 <- book1_pov[1]
response <- GET(url1)
content <- content(response)

df <- data.frame(
  name = content$name,
  gender = content$gender,
  culture = content$culture,
  born = content$born,
  died = content$died)




#wrap it in a function

get_pov_info <- function(url) {
  response <- GET(url)
  content <- content(response)
  
  df <- data.frame(
    name = content$name,
    gender = content$gender,
    culture = content$culture,
    born = content$born,
    died = content$died, stringsAsFactors = FALSE)
  
  Sys.sleep(1)
  
  df
}



#call for all - waitfor 9x 1s
all_pov_info <- purrr::map_df(book1_pov, get_pov_info)
