# ==============================================================
# title : Analysis of Top Rank songs among different streaming sites
# author: Donghyun Kang
# output: Rmarkdown
# date  : Feb/13/2018
# ==============================================================
# ## Youtube starts from 9/15, so all analysis should start from 9/15/17
#   
#   1) concat all table with another column "source" which means origination such as 
#      'spotify', 'youtube', 'billboard' and 'billboard_album' <br>
#   2) make rankinng matching ratio per weak (find same title and calculate ranking based on title or artist <br>
#   3) visualize grapth for ranking transition per artist/title comapare to each companies <br>
#===============================================================
# Inspiration :
#  ---------------------------------------------------------------
# ==============================================================

library(dplyr)
library(ggplot2)
library(ggthemes) 
#library(data.table)
#library(dygraphs) # install.packages("dygraphs")
#library(plotly)

#library(mapproj)
#library(tidyr)
#library(RSQLite)
#library(addinslist)
#library(RColorBrewer) 
#library(vcd) 
#library(xlsx) 
#library(foreign) 


#setwd("E:/Data.Science/NYCDSA/40_Projects/Shiny/Data")
setwd("C:/Users/SAMSUNG/Documents/A.MyDoc/A.DriveE/DataScience/NYCDSA/40_Projects/WebScraping/Analysis")

# Data Read/Modify/Write --------------------------------
rm(list=ls())
INIT = 1
N_RANK = 100

#raw.dt <- fread("../Data/data.csv", stringsAsFactors = F)
#raw.df <- as.data.frame(raw.dt)
df_spotify = read.csv('./spotify_wkly.csv', stringsAsFactors=FALSE)
df_youtube = read.csv('./youtubemusic.csv', stringsAsFactors=FALSE, 
                      col.names = c('start_date','end_date','rank','title','artist','views'))
df_billboard = read.csv('./acharts_singles.csv', stringsAsFactors=FALSE)
df_billboard_albums = read.csv('./acharts_albums.csv', stringsAsFactors=FALSE)
df_itunes = read.csv('./itunes.csv', stringsAsFactors=FALSE)

# check data Nas --------------------------------
df_list = c('df_spotify', 'df_youtube', 'df_billboard', 'df_billboard_albums', 'df_itunes')
print('Nas in df_spotify : ', sum(is.na(df_spotify)))
print('Nas in df_youtube : ', sum(is.na(df_youtube)))
print('Nas in df_billboard : ', sum(is.na(df_billboard)))
print('Nas in df_billboard_albums : ', sum(is.na(df_billboard_albums)))
print('Nas in df_itunes : ', sum(is.na(df_itunes)))
which( rowSums( is.na(df_spotify) ) != 0 )

# column name check --------------------------------
colnames(df_spotify)
colnames(df_youtube)
colnames(df_billboard)
colnames(df_billboard_albums)
colnames(df_itunes)

# column name tolower --------------------------------
#names(df) <- tolower(names(df))

# reorder columns --------------------------------
df_spotify <- df_spotify[c("start_date", "end_date", "rank","title", "artist", "streams")]
#df_youtube <- df_youtube[c("start_date", "end_date", "rank","title", "artist", "views")]
df_billboard <- df_billboard[c("date", "rank","title", "artist", "weeks")]
df_billboard_albums <- df_billboard_albums[c("date", "rank","title", "artist", "weeks")]
df_itunes <- df_itunes[c("date", "release_date", "title", "artist", "genre")]

# Summary --------------------------------
summary(df_spotify)
summary(df_youtube)
summary(df_billboard)
summary(df_billboard_albums)
summary(df_itunes)

# Change Variable Data Type ----------------------------------
df_spotify_org <- df_spotify
df_spotify <- df_spotify %>% 
  mutate(start_date = as.Date(start_date, "%Y-%m-%d")) %>%
  mutate(end_date = as.Date(end_date, "%Y-%m-%d")) %>%
  mutate(rank = as.integer(rank)) %>%
  mutate(streams = as.integer(streams))
which( rowSums( is.na(df_spotify) ) != 0 )
if(sum(is.na(df_spotify))!=0){
  df_spotify <- na.omit(df_spotify)
}
summary(df_spotify)

df_youtube_org <- df_youtube
df_youtube <- df_youtube %>% 
  mutate(start_date = as.Date(start_date, "%Y-%m-%d")) %>%
  mutate(end_date = as.Date(end_date, "%Y-%m-%d")) #%>%
  #mutate(rank = as.integer(rank)) # first, rank should be changed into number
which( rowSums( is.na(df_youtube) ) != 0 )
if(sum(is.na(df_youtube))!=0){
  df_youtube <- na.omit(df_youtube)
}
summary(df_youtube)

df_billboard_org <- df_billboard
df_billboard <- df_billboard %>% 
  mutate(date = as.Date(date, "%Y-%m-%d"))
which( rowSums( is.na(df_billboard) ) != 0 )
if(sum(is.na(df_billboard))!=0){
  df_billboard <- na.omit(df_billboard)
}
summary(df_billboard)

df_billboard_albums_org <- df_billboard_albums
df_billboard_albums <- df_billboard_albums %>% 
  mutate(date = as.Date(date, "%Y-%m-%d"))
which( rowSums( is.na(df_billboard_albums) ) != 0 )
if(sum(is.na(df_billboard_albums))!=0){
  df_billboard_albums <- na.omit(df_billboard_albums)
}
summary(df_billboard_albums)

df_itunes_org <- df_itunes


# reorder rows --------------------------------
df_spotify <- arrange(df_spotify, start_date, rank)
df_youtube <- arrange(df_youtube, start_date, rank)
df_billboard <- arrange(df_billboard, date, rank)
df_billboard_albums <- arrange(df_billboard_albums, date, rank)


# Data Snooping --------------------------------
head(df_spotify,5)
head(df_youtube,5)
head(df_billboard,5)
head(df_billboard_albums,5)
head(df_itunes,5)

# Data trim to synchronize -----------------------------------
df_spotify = subset(df_spotify, select = -c(end_date))
df_spotify <- df_spotify %>%
  filter(start_date >= as.Date("2017-09-15") & start_date <= as.Date("2018-01-26")) %>%
  filter(rank <= 100)
df_youtube = subset(df_youtube, select = -c(end_date))
colnames(df_billboard)[1] <- "start_date"
df_billboard$start_date = df_billboard$start_date-1 # date sync with spotify and youtube
df_billboard <- df_billboard %>%
  filter(start_date >= as.Date("2017-09-15") & start_date <= as.Date("2018-01-26")) %>%
  filter(rank <= 100)
colnames(df_billboard_albums)[1] <- "start_date" 
df_billboard_albums$start_date = df_billboard_albums$start_date-1 # date sync with spotify and youtube
df_billboard_albums <- df_billboard_albums %>%
  filter(start_date >= as.Date("2017-09-15") & start_date <= as.Date("2018-01-26")) %>%
  filter(rank <= 100)

# New column for source identification
source = rep('spotify', length(df_spotify$rank))
df_spotify$source = source

source = rep('youtube', length(df_youtube$rank))
df_youtube$source = source

source = rep('billboard', length(df_billboard$rank))
df_billboard$source = source

source = rep('billboard_albums', length(df_billboard_albums$rank))
df_billboard_albums$source = source

# Data Cleaning # remove multibyte string --------------------------------
df_spotify$title[1094] <- "Blame me"
df_spotify$title <- tolower(df_spotify$title)
df_youtube$title[165] <- "Let me down"
df_youtube$title[275] <- "Let me down"
df_youtube$title[352] <- "Let me down"
df_youtube$title[951] <- "Ready for it?"
df_youtube$title[1060] <- "Ready for it?"
df_youtube$title[1176] <- "Ready for it?"
df_youtube$title[1197] <- "Let me down"
df_youtube$title[1260] <- "Ready for it?"
df_youtube$title[1391] <- "Ready for it?"
df_youtube$title[1583] <- "Not Hot"
df_youtube$title <- tolower(df_youtube$title)
df_billboard$title <- tolower(df_billboard$title)

# Data join ---------------------------------------------------------------
df_sp = subset(df_spotify, select = -c(streams))
df_yt = subset(df_youtube, select = -c(views))
df_bb = subset(df_billboard, select = -c(weeks))
df_total = rbind(df_sp, df_yt, df_bb)

df_total$title <- tolower(df_total$title)
df_total$artist <- tolower(df_total$artist)


# Top 10 compare in every week --------------------------------------------
date_range = c(as.Date("2017-09-15"), as.Date("2017-09-21"))
rank_range = c(1, 10)

geom_User <- switch("Bar",
                    "Scatter" = geom_point(aes(color='green')),
                    "Bar" = geom_bar(aes(color='green'),stat="identity"),
                    "Histogram" = geom_histogram(aes(color='green', fill='yellow'),stat="identity"),
                    "Distribution" = geom_density(aes(fill='lime'),stat="identity"))

df_sel <- df_total %>%
  filter(start_date >= (date_range[1]) & start_date <= (date_range[2])) %>%
  filter(rank<=rank_range[2] & rank >= rank_range[1]) %>%
  mutate(rank_bar = as.numeric(11-rank))

df_sel %>% filter(source == 'spotify') %>%
#df_sel %>% filter(source == 'youtube') %>%
#df_sel %>% filter(source == 'billboard') %>%
  ggplot(aes(x=-rank, y=rank_bar, label=title )) +
  #ggplot(aes(x=artist, y=sum_Stream, label=sum_Stream )) +
  geom_bar(aes(fill= source), stat = "identity") + #, position = "dodge") +
  ggtitle(paste0("Rankings in each Sources (",rank_range[1],"~",rank_range[2],")" )) +
  geom_text(size = 3, position = position_stack(vjust = 1.2)) +
  xlab("Rank") +
  ylab("Track Name") +
  coord_flip() +
  theme_tufte()

# Arrange by rank per sources (hart to distinguish)
df_sel %>%
  ggplot(aes(x=-rank, y=rank_bar, label= paste0(title,"(",artist,")" ))) +
  geom_bar(aes(fill= source), stat = "identity" , position = "dodge") +
  #geom_label(aes(fill = source), colour = "white", fontface = "bold") +
  geom_text(size = 3, position = position_dodge(width = 0.9)) +
  ggtitle(paste0("Rankings in each Sources (",rank_range[1],"~",rank_range[2]," in week of ", date_range[1], ")" )) +
  xlab("Rank") +
  ylab("Track Name") +
  coord_flip() +
  theme_tufte()
# 
# df_sel %>% filter(source == 'spotify') %>%
#   ggplot(aes(x=artist, y=rank_bar, label=rank )) +
#   #ggplot(aes(x=artist, y=sum_Stream, label=sum_Stream )) +
#   geom_bar(aes(fill= source), stat = "identity") + #, position = "dodge") +
#   ggtitle(paste0("Rankings in each Sources (",rank_range[1],"~",rank_range[2],")" )) +
#   geom_text(size = 3, position = position_stack(vjust = 0.3)) +
#   ylab("Rank") +
#   xlab("Track Name") +
#   coord_flip() +
#   theme_tufte()

# Arranging by artist (rank is mixed but easy to see rank difference)
ggplot(df_sel, aes(x=artist, y=rank_bar, label=rank )) +
  #ggplot(aes(x=artist, y=sum_Stream, label=sum_Stream )) +
  geom_bar(aes(fill= source), stat = "identity", position = "dodge") +
  geom_text(size = 3, position = position_stack(vjust = 0.3)) +
  ggtitle(paste0("Rankings in each Sources (",rank_range[1],"~",rank_range[2]," in week of ", date_range[1], ")" )) +
  ylab("Rank") +
  xlab("Artist") +
  coord_flip() +
  theme_tufte()

# Wordcloud(p188, p184, 182) for artist and title -> To find who and which is most or least significant.
library(tm)
library(wordcloud)
library(RColorBrewer)
pal = brewer.pal(6,"RdGy")
d_artist_sp = tolower(df_sp$artist)
d_artist_yt = tolower(df_yt$artist)
d_artist_bb = tolower(df_bb$artist)

text(x=0.5, y=0.5, "Artist who is registered in Top100 more than 30 times")
wordcloud(d_artist_sp, min.freq = 30, scale = c(2,0.5), random.color = TRUE, color = pal) #, main='Title')
wordcloud(d_artist_yt, min.freq = 30, scale = c(2,0.5), random.color = TRUE, color = pal)
wordcloud(d_artist_bb, min.freq = 30, scale = c(2,0.5), random.color = TRUE, color = pal)
# ==> Now find the 10 artists who has a lot of frequency


freq_cnt_ <- function(INPUT){
  #INPUT<- scan("anuncio.txt", what="character", sep="\n")
  d_artist_sp1 <- tolower(INPUT)
  d_artist_sp2 <- strsplit(d_artist_sp1, "\\W")
  d_artist_sp3 <- unlist(d_artist_sp2)
  freq<-table(d_artist_sp3)
  freq1<-sort(freq, decreasing=TRUE)
  #temple.sorted.table<-paste(names(freq1), freq1, sep="\\t")
  temple.sorted.table<-paste(names(freq1), freq1, sep=",")
  #filename = paste(INPUT, '.txt')
  #cat("Word\tFREQ", temple.sorted.table, file=filename, sep="\n")
  return(temple.sorted.table)
}
freq_sp = freq_cnt_(d_artist_sp)
freq_yt = freq_cnt_(d_artist_yt)
freq_bb = freq_cnt_(d_artist_bb)
a=head(freq_sp,20)
b=head(freq_yt,20)
c=head(freq_bb,20)

# * Slope chart(p112) -> show how ranking differ site from site
titlelist <- function(artist_name){
  tmp <- df_total %>%
    # mutate(artist = tolower(artist)) %>%
    # mutate(title = tolower(title)) %>%  # invalid multibyte string 1094
    filter(artist == tolower(artist_name))
  list_tmp = unique(tmp$title)
  return(list_tmp)
}
#c('Post Malone', 'Kodak Black', 'Taylor swift', 'Ed Sheeran', 'Imagine Dragons')){
Lpmalone = titlelist('Post Malone')
Lkodak = titlelist('Kodak Black')
Ltaylor = titlelist('Taylor swift')
Lsheeran = titlelist('Ed Sheeran')
Limagine = titlelist('Imagine Dragons')

# To merge the same title 
Lpmalone = unique(tolower(Lpmalone))
Lkodak = unique(tolower(Lkodak))
#Ltaylor = Ltaylor[-c(7, 13)]
Ltaylor = unique(tolower(Ltaylor))
Lsheeran = unique(tolower(Lsheeran))
Limagine = unique(tolower(Limagine))

# rank trend comaprison b/w service provider
plot_trend <- function(at_sel, title_sel){
  df_total %>%
    #mutate(artist = tolower(artist)) %>%
    filter(artist == at_sel) %>%
    #mutate(title = tolower(title)) %>%
    filter(title %in% title_sel) %>%
    #group_by(source) %>%
    ggplot(aes(x=start_date, y=-1*rank, group = source)) +
    geom_point(aes(color = source)) +
    geom_line(aes(color = source)) +
    #theme_tufte() +
    #theme(plot.background = element_rect(fill = "black")) +
    #theme_wsj()+ scale_colour_wsj("colors6") +
    #theme_calc()+ scale_colour_calc() +
    theme_hc()+ scale_colour_hc() + theme(plot.background = element_rect(fill = "black")) +
    ggtitle(paste0("Weekly Ranking Trend - ", at_sel,"(",title_sel,")")) + #Selected Artists") +
    xlab("DATE") + ylab("RANKING") +
    theme(plot.title = element_text(color="white", size=14, face="bold.italic"),
          axis.title.x = element_text(color="grey", size=12),#, face="bold"),
          axis.title.y = element_text(color="grey", size=12))#, face="bold"))
}
# --------------------------------------------------
# 'Post Malone' : c("rockstar","congratulations","go flex","candy paint", "i fall apart", "white iverson")
# 'Kodak Black' : c("roll in peace", "transportin", "tunnel vision", "codeine dreaming", "no flockin", "patty cake","halloween", "patty cake", "too much money", "roll in peace")   )
# 'Taylor swift' : c(""Look What You Made Me Do", "...ready for it?", "gorgeous", "call it what you want", "end game", "i did something bad", "delicate")
# 'Ed Sheeran' : c("shape of you", "perfect", "thinking out loud") # derivative  should be merged again
# 'Imagine Dragons' : c("thunder", "believer")
# --------------------------------------------------
at_sel = tolower("Post Malone")
#title_sel = tolower(c("rockstar", "rockstar (feat. 21 savage)"))
#title_sel = tolower(c("congratulations", "congratulations (feat. quavo)"))
#title_sel = tolower(c("candy paint"))
#title_sel = tolower(c("i fall apart"))
plot_trend(at_sel,title_sel)

at_sel = tolower("Kodak Black")
#title_sel = tolower(c("roll in peace", "roll in peace (feat. xxxtentacion)"))
title_sel = tolower(c("transportin'"))
plot_trend(at_sel,title_sel)

at_sel = tolower("Taylor swift")
#title_sel = tolower(c("look what you made me do"))
#title_sel = tolower(c("...ready for it?", "ready for it?"))
#title_sel = tolower(c("gorgeous"))
title_sel = tolower(c("end game", "end game (feat. ed sheeran & future)"))
plot_trend(at_sel,title_sel)

at_sel = tolower("Ed Sheeran")
#title_sel = tolower(c("shape of you"))
#title_sel = tolower(c("perfect", "perfect duet (ed sheeran & beyoncé)", "perfect duet (feat. beyoncÉ)", "perfect symphony (feat. andrea bocelli)", "perfect duet (ed sheeran & beyoncÉ)"))
plot_trend(at_sel,title_sel)

at_sel = tolower("Imagine Dragons")
#title_sel = tolower(c("thunder"))
title_sel = tolower(c("believer"))
plot_trend(at_sel,title_sel)

# Join with genre -------------------
df_itunes= subset(df_itunes, select = -c(date, release_date, artist))
df_itunes$title <- tolower(df_itunes$title)

df_spotify_genre <- left_join(df_spotify, df_itunes, by = "title")
df_youtube_genre <- left_join(df_youtube, df_itunes, by = "title")
df_billboard_genre <- left_join(df_billboard, df_itunes, by = "title")
df_total_genre <- left_join(df_total, df_itunes, by = "title")

# frequency in genre for respective provider
wordcloud(df_spotify_genre$genre, min.freq = 1, scale = c(2,0.5), random.color = TRUE)#, color = pal)
wordcloud(df_youtube_genre$genre, min.freq = 1, scale = c(2,0.5), random.color = TRUE)#, color = pal)
wordcloud(df_billboard_genre$genre, min.freq = 1, scale = c(2,0.5), random.color = TRUE)#, color = pal)

freq_sp_genre = freq_cnt_(df_spotify_genre$genre)
freq_yt_genre = freq_cnt_(df_youtube_genre$genre)
freq_bb_genre = freq_cnt_(df_billboard_genre$genre)
# ==> genre should be surveyed more to fill all the blank,

# Hot to make Top 100 in each site -----------------------
# 1) Sportify
#     -> Total number of downloaded stream
# 2) Youtube
#     -> Total number of viewed music on YouTube by video, artist, track, and viral score:
# 3) Billboard
#     -> This week's most popular songs across all genres, 
#        ranked by radio airplay audience impressions as measured by Nielsen Music, 
#        sales data as compiled by Nielsen Music and streaming activity data provided by online music sources.




# * Mosaic map for each week per sites -> show how different the ranking is



# 1) Treemap(p75) for artist and title -> To find who and which is most or least significant.
# 2) Selected most / least artist/title 
#    line plot -> compare rankinng trend for 3 sites
#    radial plot(p151) -> compare 


# cf) Analysis by genre -> pie chart (p124,; p102,104,106,109)

# cf) bubble plot?

# Top 10 compare in every week --------------------------------------------
date_range = c(as.Date("2017-09-15"), as.Date("2017-09-21"))
rank_range = c(1, 10)

plot1 <- df_total %>%
  filter(start_date >= (date_range[1]) & start_date <= (date_range[2])) %>%
  filter(rank<=rank_range[2] & rank >= rank_range[1]) %>%
  mutate(rank_bar = as.numeric(11-rank))
  #group_by(title, source, artist) %>%
  #summarise(sum_Stream = sum(streams)) %>%
  #group_by(source) %>%
  #top_n(-rank_range[2]) 
  #top_n(rank, sum_Stream) %>%
  #arrange(source, desc(sum_Stream))





  #==> correatio ���� �� �ֳ�?  p(191?, 176, 178)
  #--> ������ũ ������� �� �ֺ� ��
  
  



























#========================================================================================================

# Data Structure Check ---------------------------------------
summary(raw.df)
head(raw.df,5)
names(raw.df)
U.ranking <- unique(raw.df$RANKING)
cat('# of ranking : \t\t', length(U.ranking)) # 100 ranks
U.track_name <- unique(raw.df$TRACK_NAME)
cat('# of unique track_name : \t', length(U.track_name)) # 9967 songs
U.regions <- as.data.frame(unique(raw.df$REGION))
names(U.regions) = "REGION"
unique(raw.df$REGION)
cat('# of unique regions : \t', length(U.regions$region_code)) # 54 Regions
U.date <- summary(raw.df$DATE)
U.date # 1/1/2017 ~ 1/9/2018
U.artist <- unique(raw.df$ARTIST)
cat('# of unique artists : \t', length(U.artist)) # 3757 artists
#mday(raw.df$DATE[1000])
str(raw.df)

# Mapping regions -----------------------------------------------
if(INIT){
  region_code = read.csv('../Data/countries.csv', header = FALSE, stringsAsFactors=FALSE)
  region_code <- region_code %>% rename(REGION = `V1`,  COUNTRY = `V2`)
  region_code$REGION = tolower(region_code$REGION)
  U.regions$REGION <- as.character(U.regions$REGION)
  region_code_join <- left_join(U.regions, region_code, by = "REGION") %>% arrange(., REGION)
  region_code_join$COUNTRY[[which(region_code_join$REGION == "global")]] = "Global"
  write.csv(region_code_join, file='./region_code_reduced.csv', row.names=FALSE)
  write.csv(region_code_join, file='../Data/region_code_reduced.csv', row.names=FALSE)
} else {
  region.dt <- fread("./region_code_reduced.csv", header=TRUE, stringsAsFactors = F)
  region.df <- as.data.frame(region.dt)
}

# "RANKING"    "TRACK_NAME" "ARTIST"     "STREAMS"    "DATE"       "REGION"

# Monthly Analysis ---------------------------------------------------------------
#  When month is selected,
#   0) scroll bar for top100 songs by ARTIST, TRACK_NAME
#   1) top100 song countries
#   2) genre
#   3) steams counts by rank
# 

# All about selected song --------------------------------------------------------
#  When song and year is selected,
#   1) global map indicate !!
type = c('Maroon 5','CCSO')
date = as.Date(c("2017-01-01", "2017-01-31"), format=("%Y-%m-%d"))
input = data.frame(type, date)
#as.POSIXct(strptime("2017-01-31", "%Y-%m-%d"))
#b = as.Date("2016-01-10", format("%Y-%m-%d"))

a<- raw.df %>%
  filter(ARTIST == input$type[1],
         DATE > (input$date[1]) & DATE < (input$date[2]), REGION %in% c("ec", "fr", "ai"))
  #arrange(REGION)
rlist = c("ec", "fr", "ai")
b<- raw.df %>%
  filter(ARTIST == input$type[1],
         DATE > (input$date[1]) & DATE < (input$date[2]), REGION %in% rlist)

start = "2007-01-01"
end = "2017-01-31"
c<- unique(raw.df %>% filter(DATE > start & DATE < end) %>% select(ARTIST))

library(ggthemes)
# b <- raw.df %>% filter(ARTIST == input$type[1])
# c <- raw.df %>% filter(DATE > (input$date[1]) & DATE < (input$date[2]))
p <- ggplot(data = a, aes(x=DATE, y=RANKING))
p + geom_point(aes(color='white')) + stat_smooth(method = "lm", se = FALSE) + facet_grid("~REGION") +
  #theme_tufte() 
  #theme(plot.background = element_rect(fill = "black"))
  #theme_tufte() + theme(plot.background = element_rect(fill = "black"))
  #theme_wsj()+ scale_colour_wsj("colors6")
  #theme_calc()+ scale_colour_calc() +
  theme_hc()+ scale_colour_hc() + theme(plot.background = element_rect(fill = "black")) +
  #theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
  #                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))



g <- ggplot(data = raw.df[1:100,], aes(x=RANKING, y=STREAMS))
g + geom_point()
#g + geom_bar(stat='identity')

## ============================================================================== Summarize Ranking 
type = c('Maroon 5','CCSO')
date = as.Date(c("2017-01-01", "2017-01-31"), format=("%Y-%m-%d"))
input = data.frame(type, date)

A<- raw.df %>%
  filter(DATE >= (input$date[1]) & DATE <= (input$date[2]), REGION %in% c("ec", "fr", "us")) %>%
  group_by(TRACK_NAME, REGION, ARTIST) %>%
  summarise(sum_Stream = sum(STREAMS)) %>%
  #tally(REGION) %>%
  arrange(REGION, desc(sum_Stream))

B <- A %>%
  group_by(REGION) %>%
  top_n(3, sum_Stream) %>%
  arrange(REGION, desc(sum_Stream))
    
# reorder for ggplot2
#B$ARTIST <- factor(B$ARTIST, levels = B$ARTIST[order(B$sum_Stream)])
#B$ARTIST <- factor(B$ARTIST, levels = order(B$sum_Stream))
B$ARTIST  # notice the changed order of factor levels

#p <- ggplot(B, aes(x=sum_Stream, y=ARTIST))
p <- ggplot(B, aes(x=ARTIST, y=sum_Stream, label=sum_Stream ))
p + ggtitle(paste0("Rankings in each Countries (",input$date[1],"~",input$date[2],")" )) +
  geom_bar(aes(fill= REGION), stat = "identity", position = "dodge") +
  geom_text(size = 3, position = position_stack(vjust = 0.5)) +
  ylab("Total played number of Streams") +
  xlab("ARTIST or Track Name") +
  coord_flip() +
  theme_tufte()
  #theme(plot.background = element_rect(fill = "black"))
  #theme_tufte() + theme(plot.background = element_rect(fill = "black"))
  #theme_wsj() #+ scale_colour_wsj("colors6")
  #theme_calc()+ scale_colour_calc() 
  #theme_hc()+ scale_colour_hc()  
  #+ theme(plot.background = element_rect(fill = "black"))
  #theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
  #                   panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
## ============================================================================== Summarize Ranking 







# ------- Lylics ----------------------------------------
raw.dt <- fread("../Data/data.csv", stringsAsFactors = F)
raw.df <- as.data.frame(raw.dt)

# Inspiration :
# By using the daily ranking of the 200 most listened songs in 53 countries by Spotify users,
# -	Track the current trend of music and forcast the next trend;
# -	Track the flow or influence of top ranked musics from one country to another, make some business model for commercial;
# -	Make a distribution map, and influence map by region, country, genre(music categories), and other information (such as season, weather, social event, etc);
# -	Check a possibility to develop a music recommendation service based on user-preference? Trend of music by states or region
#  ---------------------------------------------------------------
# Can you predict what is the rank position or the number of streams a song will have in the future?
# - How long does songs "resist" on the top 3, 5, 10, 20 ranking?
# - What are the signs of a song that gets into the top rank to stay?
# - Do continents share same top ranking artists or songs?
# - Are people listening to the very same top ranking songs on countries far away from each other?
# - How long time does a top ranking song takes to get into the ranking of neighbor countries?
# ==============================================================




head(A,1)
# ---------------------------------------------------------------------------------
# Change to time series for "STREAMS"
library(xts)
#sum(is.na(raw.df))
streams.ts <- xts(raw.df[,c(-1,-2,-3,-5,-6)], order.by=raw.df[,"DATE"])
#returns <- diff(streams.ts, arithmetic=FALSE ) - 1
row_sel = seq(1,900000,200)
#dygraph(streams.ts[row_sel])
#dygraph(streams.ts[row_sel]) %>% dyRangeSelector()
dygraph(streams.ts[row_sel]) %>%
  #dySeries("mdeaths", label = "Male") %>%
  dySeries("V1", label = "STREAMS") %>%
  #dyOptions(stackedGraph = TRUE) %>%
  dyRangeSelector(height = 20)
# ---------------------------------------------------------------------------------
lungDeaths <- cbind(mdeaths, fdeaths)
dygraph(lungDeaths)



#-------------------------------------------------------
#plotly test
library(plotly)

set.seed(100)
d <- diamonds[sample(nrow(diamonds), 1000), ]

p <- ggplot(data = d, aes(x = carat, y = price)) +
  geom_point(aes(text = paste("Clarity:", clarity)), size = 4) +
  geom_smooth(aes(colour = cut, fill = cut)) + facet_wrap(~ cut)

p <- ggplotly(p)

#tmp <- xts(raw.df[,c(-1,-2,-3,-5,-6)], order.by=as.Date(raw.df[,6], "%Y-%m-%d"))

#
#  daily returns
#

#
#  weekly open, high, low, close reports
#
to.weekly(tmp, name="Hero")

# library(readr)
# library(ggplot2)
# library(dplyr)
library(scales)
# library(forecast)
library(tseries) # install.packages("tseries")

theme_paper <- function() {
  theme_update(panel.background  = element_blank(),
               panel.grid.major  = element_blank(),
               axis.title        = element_text(size = 14, face = "bold"),
               axis.title.x      = element_text(vjust = 0.5),
               axis.title.y      = element_text(angle = 90, vjust = 1),
               axis.text         = element_text(size = 12),
               legend.title      = element_text(size = 17, face="bold"), 
               legend.text       = element_text(size = 17),
               strip.text        = element_text(size = 14),
               plot.margin       = unit(c(1, 1, 1, 1), "lines"),
               plot.title        = element_text(face="bold"))
}

theme_set(theme_bw())
theme_paper()

# Take one song that has data in one region only ("pl")
seven_nation_army = raw.df %>% 
  filter(ARTIST == "Shakira", 
         TRACK_NAME == 'Chantaje',
         REGION %in% c("gb", "ie", "pl"))

ggplot(seven_nation_army, aes(DATE, position)) +
  xlab("Date") +
  ylab("Rank position") +
  geom_point() +
  scale_y_reverse(breaks=seq(1, 200, 20)) +
  scale_x_date(breaks=date_breaks("month"),
               labels=date_format("%b")) +
  geom_smooth() +
  facet_wrap(~REGION, ncol=1)

seven_nation_army_in_pl = seven_nation_army %>%
  filter(REGION == "pl")

seven_nation_army_in_pl$streams_timeseries = ts(seven_nation_army_in_pl[, c('STREAMS')])
seven_nation_army_in_pl$streams_timeseries_week = ma(seven_nation_army_in_pl$streams_timeseries, order=7)
seven_nation_army_in_pl$streams_timeseries_month = ma(seven_nation_army_in_pl$streams_timeseries, order=30)







