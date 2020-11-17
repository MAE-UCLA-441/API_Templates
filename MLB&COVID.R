library(jsonlite)
library(dplyr)
library(rmarkdown)
library(writexl)
library(markdown)
library(knitr)

####### First API #########

#I use the lookup Service API posted on GitHub at https://appac.github.io/mlb-data-api-docs/
#The transaction endpoint provides a list of all types of transactions
#For this exercise, I will only consider "Trades" (and not free agent signings, options, DFAs, etc)
getTrades = function(dateFrom, dateTo) {
    URL = "http://lookup-service-prod.mlb.com"
    path = paste("/json/named.transaction_all.bam?sport_code='mlb'&start_date='",dateFrom,
    "'&end_date='", dateTo, "'", sep="")
    request = paste(URL, path, sep="")
    trades = fromJSON(request)
    trades = trades$transaction_all$queryResults$row %>% filter(type == "Trade")
    return(trades)
}


myTrades = getTrades(20150101, 20150601)    #Grabbing the trades from Jan 1, 2015 to Jun 1, 2015

#Here, I reduce the entire trade data into just my variables of interest: To/From teams and the date
myTrades = myTrades[c("team", "from_team", "trans_date")]

#Use: Though the example date range was small to keep file size low, the range can
#be expanded for multiple years to see possible patterns in a team's trading behavior.
#If certain teams get consistently trade-happy mid-season, this can capitalized by a team looking for careless
#transnational mistakes.
write_xlsx(myTrades,"tradeAPI.xlsx")

######## Second API ##############
#Data from the COVID Tracking Project at The Atlantic
#This data is for grabbing the historical COVID metrics from a single State. 

# Use: Its uses are wide since the metrics are wide, but here I request the user to provide a start 
# date so we can hone in on a more specific time period. I select the columns "death" and 
#"hospitalizedCurrently" to set up a possible exploration on the relationship between number of deaths
# and those hospitalized in that state (a very simple relationship, but this is just to demonstrate).

getStateData = function(state, startDate){
    URL = "https://api.covidtracking.com/v1/states/"
    path = paste(state,"/daily.json", sep = "")
    request = paste(URL, path, sep = "")
    # print(request)
    stateData = fromJSON(request)
    stateData = stateData %>% filter(date>startDate)
    stateData = stateData[c("death","hospitalizedCurrently")]
    return(stateData)
}

myState = getStateData("ma",20200701)   #Grabbing the data for California from Jul 1 to the most recent date
write_xlsx(myState, "covidAPI.xlsx")

