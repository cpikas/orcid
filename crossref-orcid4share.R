# using the crossref API to find researcher orcids , ouput is a csv with names and orcids
# Christina Pikas cpikas@gmail.com
# https://github.com/cpikas/orcid

# note: I've tried to delete out individual details and things about MPOW (my place of work)
# note2: read the documentation about adding your e-mail to your .Renviron so you get put in the friendly pool
# 2 ways: use known DOIs and pull down orcids or search there for affil and then pull down orcids

#filters:
# has_orcid	{logical}	metadata which includes one or more ORCIDs
# orcid	{orcid}	metadata where <orcid> element's value = {orcid}
# affiliation		metadata for records with at least one contributor with the given affiliation

#. Pass these options in to the cr_*() functions in the filter parameter as a list, e.g., filter=list(has_funder=TRUE, has_full_text=TRUE)
###
library("readr")
library("rcrossref")


#sample search
res<- cr_works(filter= c(has_orcid = TRUE) , flq= c(query.affiliation='term+term+term'))

head(res)
str(res$data)
###
# here's part of the output
# $ author          :List of 20
#   ..$ :Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	10 obs. of  6 variables:
# .. ..$ ORCID              : chr  "http://orcid.org/0000- " "http://orcid.org/0000-0 " "http://orcid.org/0000- " NA ...
# .. ..$ authenticated.orcid: logi  FALSE FALSE FALSE NA FALSE FALSE ...
# .. ..$ given              : chr  "first1" "first2" "first3" "first4" ...
# .. ..$ family             : chr  "last1" "last2" "last3" "last4" ...
# .. ..$ sequence           : chr  "first" "additional" "additional" "additional" ...
# .. ..$ affiliation.name   : chr  "MPOW" "MPOW" "MPOW" "MPOW" ...

# extracting the needed data
res$data$author[[1]]
authors<-as.data.frame(res$data$author[[1]])
authors<-data.frame(ORCID=authors$ORCID,given=authors$given,family=authors$family,affiliation_name=authors$affiliation.name)

#making a dataframe in chunks
for (i in (1:1000)){
  holddf<- as.data.frame(res$data$author[[i]])
  if(!"affiliation.name" %in% colnames(holddf)){holddf$affiliation.name<-holddf$affiliation1.name}
  holddff<-data.frame(ORCID=holddf$ORCID,given=holddf$given,family=holddf$family,affiliation_name=holddf$affiliation.name)
  authors<-rbind(authors,holddff)
}
# trying other searches - the cursor part will fetch longer results than the default max
res<- cr_works(filter= c(has_orcid = TRUE) , flq= c(query.affiliation='my place of work'), cursor = "*", cursor_max = 5000, limit = 200,.progress = TRUE)

restest<- cr_works(filter=c(has_orcid= TRUE), flq=c(query.affiliation='mpow+city'))
#note the max offset is larger than noted in the package documentation
res<- cr_works(filter=c(has_orcid= TRUE), flq=c(query.affiliation='my place+of work'),offset = 1000, limit = 1000)

#could do a lot more cleaning here, but I dumped to Excel and did it there
write_csv(authors,"authorcid.csv")

