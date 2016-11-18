#data for the leaflet graph
dataUrl <- "http://en.openei.org/wiki/Special:Ask/-5B-5BCategory:Energy-20Generation-20Facilities-5D-5D-5B-5BSector::Wind-20energy-5D-5D/-3F%3DFacility-20Name-23/-3FFacility/-3FFacilityType/-3FOwner/-3FDeveloper/-3FEnergyPurchaser/-3FPlace/-3FGeneratingCapacity/-3FNumberOfUnits/-3FCommercialOnlineDate/-3FWindTurbineManufacturer/-3FFacilityStatus/-3FCoordinates/format%3Dcsv/limit%3D2500/mainlabel%3DFacility-20Name/offset%3D0"

# custom icon
iconFile <- "./data/Windmill-02.png"
windMillIcon <- makeIcon(iconFile)

# if the file does not exist download it
windFarmDataFile <- "./data/windFarmData.csv"
if (!file.exists("./data")) {
  dir.create("./data")
}

if (!file.exists(windFarmDataFile)) {
  download.file(dataUrl, destfile=windFarmDataFile)
}

#read the data from the file
windFarmDataSet <- read.csv(windFarmDataFile, header=TRUE, as.is = TRUE, stringsAsFactors = FALSE, sep=',', na.strings=c('NA','','#DIV/0!'))

# Only show the farms that are in service
windFarmDataSet <- windFarmDataSet[windFarmDataSet$FacilityStatus == "In Service",]

# Only show the wind farms in Calafornia
windFarmDataSet <- windFarmDataSet[grepl("CA", windFarmDataSet$Place),]

#Split the coordinates into longitude and lattitude
windFarmDataSet <- extract(data=windFarmDataSet, col=Coordinates, into=c("lat", "lng"), regex="(.*),(.*)")

windFarmDataSet$Info <- paste(windFarmDataSet$Facility.Name, ... = windFarmDataSet$GeneratingCapacity, sep="<br> ")
    
# Remove units from the longitude and lattitude
windFarmDataSet$lat <- str_replace(windFarmDataSet$lat, "°", "")
windFarmDataSet$lng <- str_replace(windFarmDataSet$lng, "°", "")

# make the longitude and lattitude numeric 
windFarmDataSet$lat <- as.numeric(windFarmDataSet$lat)
windFarmDataSet$lng <- as.numeric(windFarmDataSet$lng)

#plot the graph
windFarmDataSet %>%
    leaflet() %>%
    addTiles() %>%
    addMarkers(lng=~lng, lat=~lat, clusterOptions = markerClusterOptions(),  icon=windMillIcon, popup=~Info)