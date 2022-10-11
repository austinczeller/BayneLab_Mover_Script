library(wildRtrax)
library(dplyr)
library(reticulate)
library(lubridate)
####PATH VARIABLES####
BUpubilic_prefix<- "P:/"
org<-"ABMI"
project<-"ABMI-EH"
year<-"2020"
visit<-"V1"

####Sampling & Moving Variables####
numberofrecordings<-"20"
file_destination<-"W:/BayneLabWorkSpace/YOURWORKSPACE" #location you want to move your files

####Reading location list####
locations<-read.csv("locations.csv")
colnames(locations)[1] <-gsub('^...','',colnames(locations)[1])
#gsub argument is to correct errors that are associated with .csv's downloaded from WildTrax
locs<-c(locations$location)

renamed_paths<-c()
####Mover Script####

for(i in 1:nrow(locations)){
  location<-locs[i]
  PATH<-paste(BUpubilic_prefix,org,"/","ARU/",project,"/",year,"/",location,"/",sep="") 
  #There are discrepancies between ABMI and BU file path patterns, so make sure PATH matches your organization's pattern. 
  renamed_paths<-append(renamed_paths,PATH)
  
  files<-tibble("x"=list.files(path=renamed_paths[i],pattern=".wa",recursive=TRUE))
 
  #Gathering metadata for filtering functions. For pure random sampling do not run filtering functions.
  #Functions can be altered to get desired filters. Default is only recordings from 4am-10am.
  files<-wt_audio_scanner(renamed_paths[i],file_type = "both") #Here you can filter for 
  files<-files%>%mutate(hour=hour(files$recording_date_time))
  files<-files%>%filter(hour%in%c(4:10))
  
  #Randomly sampling from file list
  sample<-sample_n(files,numberofrecordings,replace=TRUE)
  sample<-tibble(paste(renamed_paths[i],sample$x, sep=""))
  sample<-rename(sample,x=`paste(renamed_paths[i], sample$x, sep = "")`)
  #Mover script in R
  
  file.copy(sample$x,file_destination)
  }
print("Transfer Complete")


