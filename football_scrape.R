library(rvest)
library(RSelenium)
library(wdman)
library(tidyverse)
library(stringr)
library(urltools)


remDr <- remoteDriver(remoteServerAddr = "192.168.99.100",
                      port=4445L)
remDr$open()

squad <- read_csv("squadsize.csv")
df <- read_csv("epldata.csv")
#View(squad)
squad <- squad %>% mutate(upper=cumsum(size),lower=lag(upper))
squad[1,"lower"] <- 0

df <- tibble(id=1:465,Team=NA,Player=NA)


for(number in 1:20){
  upper <- as.numeric(squad[number,"upper"])
  lower <- as.numeric(squad[number,"lower"])
  size <- as.numeric(squad[number,"size"])

  temp <- df %>% filter(row_number() > lower & row_number() <= upper) %>%
    mutate(Team = number,Player = seq(1,size))
  df <- rbind(df,temp)
  #print(size)

}

df <- df %>% filter(row_number() > 465)
df <- df %>% mutate(lagTeam=lag(Team))
df[1,"lagTeam"] <- 0
#df1 <- df %>% filter(row_number() < 30)
FantasyExtract <- function(Team,lagTeam,Player){

  url <- paste0("https://fantasy.premierleague.com/a/statistics/total_points/te_",Team)
  if(Team != lagTeam){
    remDr$navigate(url)
    Sys.sleep(1.5)
    print("chocolate")

  }

  tryit <- try(remDr$findElement("css",paste0("tr:nth-child(",Player,") .ism-table--el__name"))$getElementText())
  if(inherits(tryit, "try-error")) {
    print(paste0("Name error, ",Team," ",Player))
    name <- ""
  }
  else{
    #name <- ""
    name <- as.character(remDr$findElement("css",paste0("tr:nth-child(",Player,") .ism-table--el__name"))$getElementText())
    #print(Encoding(name))
  }

  tryit <- try(remDr$findElement("css",paste0("tr:nth-child(",Player,") .ism-table--el__primary+ td"))$getElementText())
  if(inherits(tryit, "try-error")) {
    print(paste0("FPL Value error, ",Team," ",Player))
    fplValue <- ""
  }
  else{
    fplValue <- as.character(remDr$findElement("css",paste0("tr:nth-child(",Player,") .ism-table--el__primary+ td"))$getElementText())
  }

  tryit <- try(remDr$findElement("css",paste0("tr:nth-child(",Player,") td:nth-child(6)"))$getElementText())
  if(inherits(tryit, "try-error")){
    print(paste0("FPL Points error, ",Team," ",Player))
    fplPoints <- ""
  }
  else{
    fplPoints <- as.character(remDr$findElement("css",paste0("tr:nth-child(",Player,") td:nth-child(6)"))$getElementText())
  }

  tryit <- try(remDr$findElement("css",paste0("tr:nth-child(",Player,") td:nth-child(4)"))$getElementText())
  if(inherits(tryit, "try-error")){
    print(paste0("FPL Select error, ",Team," ",Player))
    fplSel <- ""
  }
  else{
    fplSel<- as.character(remDr$findElement("css",paste0("tr:nth-child(",Player,") td:nth-child(4)"))$getElementText())
  }
  print(paste0(Team,",",Player))
  x <- paste0(name,",",fplValue,",",fplSel,",",fplPoints)
  return(as.character(x))

}
df1 <- df
#df1 <- df1 %>% filter(row_number() <30)
df <- df1 %>%rowwise() %>%               #filter(Team==1) %>% filter(Player %in% c(1:5)) %>%
  mutate(fplData=FantasyExtract(Team,lagTeam,Player))
View(df)
df$fplData <- iconv(df$fplData, from = "UTF-8", to = "LATIN1")

as.character(df[1,"fplData"])

write_csv(df,"epldata.csv")
#Now, let's split up the data.

teamName <- function(x){
  return(as.character(squad %>% filter(number == x) %>% select(team)))
}

searchName <- function(x,team){
  num <- team
  tem <- as.character(squad %>% filter(number == num) %>% select(team))
  return(paste0(x,"+",tem,"+wiki"))
}

retrieve_Name <- function(x){
  p <- as.data.frame((str_locate_all(string = x,pattern = ",")))
  name <- str_sub(x,start=0,end=p[1,1]-1)
  return(name)
}

retrieve_fplValue <- function(x){
  p <- as.data.frame((str_locate_all(string = x,pattern = ",")))
  val <- str_sub(x,start=p[1,1]+2,end=p[2,1]-1)
  return(val)
}

retrieve_fplSel <- function(x){
  p <- as.data.frame((str_locate_all(string = x,pattern = ",")))
  sel <- str_sub(x,start=p[2,1]+1,end=p[3,1]-1)
  return(sel)
}

retrieve_fplPoints <- function(x){
  p <- as.data.frame((str_locate_all(string = x,pattern = ",")))
  points <- str_sub(x,start=p[3,1]+1)
  return(points)
}

df <- df %>% rowwise() %>%
  #mutate(x=as.character(fplData))
  mutate(Name=retrieve_Name(fplData),searchTerm=searchName(Name,Team),fplValue=retrieve_fplValue(fplData),
         fplSel=retrieve_fplSel(fplData),fplPoints=retrieve_fplPoints(fplData))


write_csv(df,"epldata.csv")


#Ouch - now we go to Wikipedia again. We'll extract the heading of each article.

retrieve_Wiki <- function(tag){

  url <- paste0("https://www.google.co.in/#q=",tag)
  remDr$navigate(url)
  Sys.sleep(1.5)
  print(tag)
  tryit <- try(remDr$findElement("css","._Rm")$getElementText())
  if(inherits(tryit, "try-error")){
    # do something when error
    print(" Error")
    return("")
  }
  else {
    link <- remDr$findElement("css","._Rm")$getElementText()
    return(link)
  }
}
#dfx <- df %>% filter(id< 20)
#View(df)
#temp <- df %>% filter(id > 430)
df <- df %>%rowwise() %>%
  mutate(Wiki=retrieve_Wiki(searchTerm))
df$Wiki <- as.character(df$Wiki)

#Retrieved wiki links
retrieve_PageViews <- function(wiki){
  if(wiki == "")
    return(0)
  wiki <- gsub("/","0",wiki)
  p <- as.data.frame((str_locate_all(string = wiki,pattern = "0")))
  wiki_tag <- str_sub(wiki,start=p[dim(p)[1],1]+1)
  url <- paste0("https://tools.wmflabs.org/pageviews/?project=en.wikipedia.org&platform=all-access&agent=user&start=2016-09-01&end=2017-05-01&pages=",wiki_tag)
  remDr$navigate(url)
  Sys.sleep(2.5)
  tryit <- try(remDr$findElement("css",".single-page-stats")$getElementText())
  if(inherits(tryit, "try-error") | remDr$findElement("css",".single-page-stats")$getElementText()==""){
    # do something when error
    print("Error")
    return(0)
  }
  else {
    # do something when no error
    pop <- remDr$findElement("css",".single-page-stats")$getElementText()
    print(paste0(wiki_tag," ",pop))
    return(pop)
  }
}

#dfx <- df %>% filter(id< 7)
#View(df)
df <-  df %>%rowwise() %>%
  mutate(PageViews=retrieve_PageViews(Wiki))
df$PageViews <- as.character(df$PageViews)

retrieve_fullName <- function(wiki){
  if(is.na(wiki))return("")
  wiki <- gsub("/","0",wiki)
  p <- as.data.frame((str_locate_all(string = wiki,pattern = "0")))
  wiki_tag <- str_sub(wiki,start=p[dim(p)[1],1]+1)
  p <- as.data.frame((str_locate_all(string = wiki_tag,pattern = "\\(")))
  rows <- nrow(p)
  if(rows == 0){
    return(wiki_tag)
  }
  return(str_sub(wiki_tag, end=p[1,1]-2))
}

df <- df %>% rowwise() %>%
  mutate(fullName=retrieve_fullName(Wiki))


#Finally, scraping from TransferMrkt! I hope they don't block me.
translation <- function(x){
  x <- gsub("á","a",x)
  x <- gsub("ó","o",x)
  x <- gsub("í","i",x)
  x <- gsub("é","e",x)
  x <- gsub("ð","d",x)
  x <- gsub("ć","c",x)
  x <- gsub("ø","o",x)
  x <- gsub("ú","u",x)
  x <- gsub("ï","i",x)
  x <- gsub("ö","o",x)
  x <- gsub("ü","u",x)
  x <- gsub("ğ","g",x)
  x <- gsub("ë","e",x)
  x <- gsub("ß","ss",x)
  x <- gsub("ř","r",x)
  x <- gsub("ë","e",x)
  x <- gsub("ä","a",x)
  x <- gsub("š","s",x)
  x <- gsub("Č","C",x)
  x <- gsub("Ö","O",x)
  #x <- gsub("","O",x)
  return(x)
}



for(i in 1:nrow(df)){
  x <- df[i,"fullName"]
  if(x == "")next
  x <-gsub("_", "+", x)
  x <- translation(x)
  #print(x)
  url <- paste0("https://www.transfermarkt.com/schnellsuche/ergebnis/schnellsuche?query=",x,"&x=0&y=0")
  tryit <- try(read_html(url))
  if(inherits(tryit, "try-error")){
    print("Well Fuck.")
    next# do something when error
  }
  webpage <- read_html(url)
  test <- html_node(webpage,'.spielprofil_tooltip')
  if(is.na(html_attr(test,'href'))){
    print(i)
    next
  }


  value <- html_node(webpage,".odd:nth-child(1) .rechts.hauptlink")
  df[i,"Value"] <- html_text(value)

  position <- html_node(webpage,"#yw0 .odd:nth-child(1) .zentriert:nth-child(2)")
  df[i,"Position"] <- html_text(position)

  age <- html_node(webpage,"#yw0 .odd:nth-child(1) .zentriert:nth-child(4)")
  df[i,"Age"] <- html_text(age)
  print(paste0("Success ",i))
}

write_csv(df,"epldata.csv")

isMill <- function(value){
  p <- str_locate(value,"Mill")
  if(is.na(p[1]))return(0)
  else
    return(1)
}
football <- df

football <- football %>% rowwise() %>%
  mutate(Million=isMill(Value))

# p <- str_locate(str," ")
# p[1]
# p["start"]
# str <- football[4,"Value"]
# x <- str_sub(str,end=p[1]-1)
# as.numeric(gsub(",",".",x))


FinalValue <- function(value,Million){
  p <- str_locate(value," ")
  val <- as.numeric(gsub(",",".",str_sub(value,end=p[1]-1)))

  if(Million == 0)
    return(val/1000)

  return(val)
}

football <- football %>% rowwise() %>%
  mutate(FinalValue=FinalValue(Value,Million))

write_csv(football,"master.csv")

FinalPosition <- function(x){
  if(is.na(x))return(0)
  if(x == "AM" | x == "SS" | x == "RW" | x == "LW" | x =="CF")
    return(1)
  #1 for attacking players
  else if(x == "RM" | x == "LM" | x == "CM" | x == "DM")
    return(2)
  #2 for midfielders
  else if(x == "CB" | x == "LB" | x == "RB")
    return(3)
  #3 for defenders
  else
    return(4)
  #4 for goalkeeper
}

football <- football %>% rowwise() %>%
  mutate(FinalPosition=FinalPosition(Position))

FindViews <- function(x){
  #x <- "Lucas Digne Â· Â· 9/1/2016 - 5/1/2017 Â· 175,710 pageviews (723/day)"

  p <- as.data.frame(str_locate_all(x,pattern = "\\("    ))#)
  x <- gsub("/","#",x)
  p2 <- as.data.frame((str_locate_all(string = x,pattern = "#")))
  m <- str_sub(x,start=p[dim(p),1]+1,end=p2[dim(p2),1]-1)
  m <- gsub(",","",m)
  return(as.integer(m[1]))
}

football <- football %>% rowwise() %>%
  mutate(FinalPageViews = FindViews(PageViews))

whichClub <- function(x){
  num <- x
  return(as.character(squad %>% filter(number == num) %>% select(team)))
}
#squad
#as.character(squad %>% filter(number == 4) %>% select(team))
football <- football %>% rowwise() %>%
  mutate(Club = whichClub(Team))

View(football)
write_csv(df,"epldata.csv")

#Okay, now to put it in a presentable form.
df <- read_csv("epldata.csv")

df <- df %>% select(name=fullName,club=Club,age=Age,position=Position,
                    position_cat=FinalPosition,market_value=FinalValue,
                    page_views=FinalPageViews,fpl_value=fplValue,
                    fpl_sel=fplSel,fpl_points=fplPoints)

View(df)
write_csv(df,"epldata_final.csv")

df <- read_csv("epldata_final.csv")
#Need to add nationality!

getNation <- function(x){
  if(x == "")next
  x <-gsub("_", "+", x)
  x <- translation(x)
  #print(x)
  url <- paste0("https://www.transfermarkt.com/schnellsuche/ergebnis/schnellsuche?query=",x,"&x=0&y=0")
  tryit <- try(read_html(url))
  if(inherits(tryit, "try-error")){
    print("Well Fuck.")
    return(NA)# do something when error
  }

  nation <- read_html(url) %>%
    html_nodes('.flaggenrahmen') %>%
    html_attr("title")
  nation <- nation[1]
  print(paste0("Success ",nation))
  return(as.character(nation))

}
df <- df %>% rowwise() %>%
  mutate(nationality=getNation(name))

#Might as well clean up the names as well.

cleanName <- function(x){
  x <-gsub("_", " ", x)
  x <- translation(x)
  return(x)
}
df <- df %>% rowwise() %>%
  mutate(name=cleanName(name))

#New signings from foreign clubs
df <- df %>% mutate(new_foreign=ifelse(is.na(new_foreign),0,1))

ageCat <- function(age){
  if (age < 22)return(1)
  else if( age < 25)return(2)
  else if( age < 28)return(3)
  else if( age < 31)return(4)
  else if( age < 34)return(5)
  else return(6)
}
df <- df %>%rowwise() %>% mutate(age_cat=ageCat(age))
df <- df %>% mutate(age_cat = as.factor(age_cat))

df <- df %>% mutate(position_cat =ifelse(position_cat == 4,3,position_cat),
                    position_cat= as.factor(position_cat),
                     region=as.factor(region))

write_csv(df,"epldata_final.csv")

