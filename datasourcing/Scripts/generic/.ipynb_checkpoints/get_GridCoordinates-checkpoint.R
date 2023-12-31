

#' create a regular grid of 5 km *5 km resolution and create gps readings. 
#'
#' @param country 
#' @param useCaseName 
#' @param Crop 
#' @param resltn is either 0.05 (for 5 km by 5 km) or 0.01 (for 1km by 1km) or 0.0025 (for 250m by 250m)
#' @param provinces is NULL by default if data should be filtered for provinces (1st level admin zones) give the list here.
#' @param district is NULL by default if data should be filtered for districts (2nd level admin zones) give the list here.
#'
#' @return a dat frame with lon, lat, country, admin 1, admin 2. 
#' @export
#'
#' @examples getCoordinates(country = "Malawi", useCaseName = "Solidaridad", Crop = "Soybean", provinces="Kasungu", district =NULL)
getCoordinates <- function(country, useCaseName, Crop, resltn, provinces=NULL, district =NULL){ 
  
  pathOut <- paste("~/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_", useCaseName,"/", Crop, "/raw/", sep="")
  
  if (!dir.exists(pathOut)){
    dir.create(file.path(pathOut), recursive = TRUE)
  }
  
  
  ## get country abbreviation to used in gdam function
  # countryCC <- countrycode(country, origin = 'country.name', destination = 'iso3c')
  
  ## read the relevant shape file from gdam to be used to crop the global data
  countrySpVec <- geodata::gadm(country, level = 2, path='.')
  
  
  if(!is.null(provinces)){
    level3 <- countrySpVec[countrySpVec$NAME_1 %in% provinces ]
  }else if (!is.null(district)){
    level3 <- countrySpVec[countrySpVec$NAME_2 %in% district, ]
  }else{
    level3 <- countrySpVec
  }
  
  xmin <- ext(level3)[1]
  xmax <- ext(level3)[2]
  ymin <- ext(level3)[3]
  ymax <- ext(level3)[4]
  
  ## define a rectangular area that covers the whole study area (with buffer 0.1 degree added)
  lon_coors <- unique(round(seq(xmin - 0.05, xmax + 0.05, by=resltn), digits=3))
  lat_coors <- unique(round(seq(ymin - 0.05, ymax + 0.05, by=resltn), digits=3))
  rect_coord <- as.data.frame(expand.grid(Longitude = lon_coors, Latitude = lat_coors))
  

  if(resltn == 0.05){
    rect_coord$x <- floor(rect_coord$Longitude*10)/10 + ifelse(rect_coord$Longitude - (floor(rect_coord$Longitude*10)/10) < 0.05, 0.025, 0.075)
    rect_coord$y <- floor(rect_coord$Latitude*10)/10 + ifelse(abs(rect_coord$Latitude)-(floor(abs(rect_coord$Latitude)*10)/10) < 0.05, 0.025, 0.075)
    rect_coord <- unique(rect_coord[,c("x", "y")])
  }else if (resltn == 0.01) {
    rect_coord$x <- floor(rect_coord$Longitude*100)/100
    rect_coord$y <- floor(rect_coord$Latitude*100)/100 
    rect_coord <- unique(rect_coord[,c("x", "y")]) 
  }else{
   names(rect_coord) <- c("x", "y") 
  }

  
  State_LGA <- as.data.frame(raster::extract(countrySpVec, rect_coord))
  State_LGA$lon <- rect_coord$x
  State_LGA$lat <- rect_coord$y
  State_LGA$country <- country
  
  State_LGA <- unique(State_LGA[, c("country", "NAME_1", "NAME_2", "lon", "lat")])
  State_LGA <- State_LGA[!is.na(State_LGA$NAME_1), ]
  

  
 saveRDS(State_LGA, paste("~/agwise-datacuration/dataops/datacuration/Data/useCase_", country, "_",useCaseName, "/", Crop, "/result/AOI_GPS.RDS", sep=""))
  
  return(State_LGA)
}





