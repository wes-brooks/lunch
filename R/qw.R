library(dataRetrieval) #Gives us importRDB1 function
library(dplyr) #Gives us the %>% (pipe) operator
library(reshape2)

#Import an RDB that came from QWData
qw = importRDB1("data/grass_qw_out")
head(qw)

#Rename the 40A and 40B events because the letter suffix screws up the script
#qw$SCMFL[qw$SCMFL=="GSFLDWN-640A"] = "GSFLDWN-651"
#qw$SCMFL[qw$SCMFL=="GSFLDWN-640B"] = "GSFLDWN-652"
for (col in which(substring(colnames(qw), 1, 1)=="P")) {
    qw[,col] = as.numeric(qw[,col])
}

#The observations are coded by event and station. We want to look at event vs. station
qw$event = substring(qw$SCMFL, 10,12)
qw$station = strsplit(qw$SCMFL, "[-_]") %>% sapply(function(x) x[1])

#Just a fun plot:
qw %>%
    select(station, event, SAMPL, P00530) %>%
    melt(id.vars = c("station", "event", "SAMPL")) %>%
    dcast(event~variable, fun.aggregate=mean, na.rm=TRUE) %>%
    plot

#Get lists of the events, stations, and output variables:
events = unique(qw$event)
stations = unique(qw$station)
outputs = c("SAMPL", "DATES", "TIMES", "EDATE", "ETIME", "LABNO")
outputs = c(outputs, colnames(qw)[substring(colnames(qw),1,1)=="P"])

    
#Populate a wide matrix:
wide = matrix(NA, 0, length(outputs)*length(stations))
for (ev in events) {
    row = vector()
    headers = vector()
    
    for (st in stations) {
        
        samples = unique(qw$SAMP[qw$event==ev & qw$station==st])
        indx = which(qw$event==ev & qw$station==st)
        
        if (length(indx > 0)) {
            row = c(row, qw[indx,outputs])
        } else {
            row = c(row, rep(NA, length(outputs)))
        }
        headers = c(headers, paste(st, outputs, sep='.'))
    }
    names(row) = headers
    wide = rbind(wide, row)
}

rownames(wide) = events
