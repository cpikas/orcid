# using the orcid API to find researcher orcids , ouput is a csv with names and orcids
# Christina Pikas cpikas@gmail.com
# https://github.com/cpikas/orcid

# note: I've tried to delete out individual details and things about MPOW (my place of work)

library("rorcid", lib.loc="C:/R/R-3.5.3/library")



mpow_authors<-orcid(defType = "edismax",
              query = "affiliation-org-name:((my place OR mp) AND (ow work OR ow))",
              recursive = TRUE)

attr(mpow_authors,"found")
str(mpow_authors)

mpow_authors2<-orcid(defType = "edismax",
                    query = "affiliation-org-name:((my place OR mp) AND (ow work OR ow))",
                    start=101, rows=100)
View(mpow_authors2)
details<-orcid_person(mpow_authors$`orcid-identifier.path`)
details2<-orcid_person(mpow_authors2$`orcid-identifier.path`)

get_details_df<- function(staff){
  thisOrcid<-as.character(flatten(details2[staff])$name$path)
  last<-as.character(flatten(details2[staff])$name$`family-name`$value)
  first<-as.character(flatten(details2[staff])$name$`given-names`$value)
  holddf<-data.frame(orcid=thisOrcid, last=last, first=first)
  return(holddf)
}


for (i in 1:length(details2)){
  hold<-get_details_df(i)
  mpowOrcids<-rbind(mpowOrcids,hold)
}
#could definitely do things like unique() and which[] to limit to only what you want
#i did more cleanup in excel because i'm lazy

write_csv(mpowOrcids,"mpoworcids.csv")
