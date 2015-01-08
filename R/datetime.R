file = "data/tb_mid_2014"

dt <- read.delim(  
    file, 
    header = TRUE,
    colClasses=c('character'),
    comment.char="#")

offsetLibrary <- setNames(c(5, 4, 6, 5, 7, 6, 8, 7, 9, 8, 10, 10),
                          c("EST","EDT","CST","CDT","MST","MDT","PST","PDT","AKST","AKDT","HAST","HST"))

dt$dateTime <- as.POSIXct(paste(dt$DATE, dt$TIME), format="%Y%m%d %H%M%S", tz="UTC")
dt$dateTime <- dt$dateTime + offsetLibrary[dt$TZCD]*60*60

dt$DATE <- as.POSIXct(dt$DATE, format="%Y%m%d")
dt$VALUE <- as.numeric(dt$VALUE)
dt$PRECISION <- as.numeric(dt$PRECISION)

#See how x$datetime looks during the switch from standard to daylight time:
timechange = which(dt$TZCD == "CDT")[1]
dt[(timechange-5):(timechange+5),]
