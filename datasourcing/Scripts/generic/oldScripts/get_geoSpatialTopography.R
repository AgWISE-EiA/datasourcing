#################################################################################################################
## sourcing required packages 
#################################################################################################################
packages_required <- c("terra", "sf", "rgl", "rgdal", "sp", "geodata", "tidyverse", "geosphere", "countrycode")

# check and install packages that are not yet installed
installed_packages <- packages_required %in% rownames(installed.packages())
if(any(installed_packages == FALSE)){
  install.packages(packages_required[!installed_packages])}

# load required packages
invisible(lapply(packages_required, library, character.only = TRUE))

#################################################################################################################
## functions to download DEM from the package Geodata, crop and write the result in "useCaseName/Crop/raw"
#################################################################################################################
#' the DEM layer is aggregated at 38m res and are obtained using geodata; for info on variables and units refer to
#' @param country country name
#' @param useCaseName use case name
#' @param Crop the name of the crop to be used in creating file name to write out the result.
#' @param overwrite default is FALSE 
#'
#' @return raster files cropped from global data and the result will be written out in useCaseName/Crop/raw/Topography
#'
#' @examples crop_geoSpatial_Topography(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", overwrite = TRUE)
# TODO change the name to get_Topography_Data
crop_geoSpatial_Topography <- function(country, useCaseName, Crop, overwrite){
  
  ## create a directory to store the cropped data:  
  pathOut <- paste("/home/jovyan/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_",useCaseName, "/", Crop, "/raw/Topography", sep="")
  
  
  if (!dir.exists(pathOut)){
    dir.create(file.path(pathOut), recursive = TRUE)
  }
  
  ## read the relevant shape file from gdam to be used to crop the global data
  countryShp <- geodata::gadm(country, level = 3, path='.')
  
  ## download dem layers from country extent, mosaic and crop
  countryExt<-terra::ext(countryShp)
  listRaster_dem1 <-geodata::elevation_3s(lon=countryExt[1], lat=countryExt[3], path=pathOut) #xmin - ymin
  listRaster_dem2 <-geodata::elevation_3s(lon=countryExt[1], lat=countryExt[4], path=pathOut) #xmin - ymax
  listRaster_dem3 <-geodata::elevation_3s(lon=countryExt[2], lat=countryExt[3], path=pathOut) #xmax - ymin
  listRaster_dem4 <-geodata::elevation_3s(lon=countryExt[2], lat=countryExt[4], path=pathOut) #xmax - ymax
  listRaster_dem <- terra::mosaic(listRaster_dem1, listRaster_dem2, listRaster_dem3, listRaster_dem4, fun='mean')
  
  croppedLayer_dem <- terra::crop(listRaster_dem, countryShp)
 
  ## save result
  terra::writeRaster(croppedLayer_dem, paste0(pathOut, "/dem.tif", sep=""), filetype="GTiff", overwrite = overwrite)
 
  return(croppedLayer_dem)
}



#################################################################################################################
## functions to read from "useCaseName/Crop/raw" and do data processing/derived variables etc and write the result in "UseCase/Crop/transform"
#################################################################################################################

#' @description function to derive topography variables (slope, tpi and tri)
#' @param country country name
#' @param useCaseName use case name  name
#' @param Crop the name of the crop to be used in creating file name to write out the result.
#' @param overwrite default is FALSE 
#' @param pathOut path to save the result: TODO When the data architect (DA) is implemented pathOut = "usecaseName/crop/transform/topography"
#' @examples derive_topography_data(country= "Rwanda", useCaseName = "RAB", Crop = "Potato", overwrite = TRUE)

derive_topography_data <- function(country, useCaseName, Crop, overwrite=FALSE){
  
  ## create a directory to store the derived data

 pathOut <- paste("/home/jovyan/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_",useCaseName, "/", Crop, "/transform/Topography", sep="")
 
  if (!dir.exists(pathOut)){
    dir.create(file.path(pathOut), recursive = TRUE)
  }
  
  pathIn <- paste("/home/jovyan/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_",useCaseName, "/",Crop, "/raw/Topography", sep="")
 
  
  ## read, crop, calculate and save the raster files
  dem <- terra::rast(paste(pathIn, "dem.tif", sep="/"))
  
  terra::writeRaster(dem, filename = paste0(pathOut,"/dem.tif", sep=""), filetype = "GTiff", overwrite=overwrite)
  slope <- terra::terrain(dem, v = 'slope', unit = 'degrees', filename = paste0(pathOut,"/slope.tif", sep=""), overwrite=overwrite)
  tpi <- terra::terrain(dem, v = 'TPI', filename = paste0(pathOut,"/tpi.tif", sep=""), overwrite=overwrite)
  tri <- terra::terrain(dem, v = 'TRI', filename = paste0(pathOut,"/tri.tif", sep=""), overwrite=overwrite)
  
}



#' Title extracting the point topography data for GPS of trial location from dem derived data 
#' @description this functions loops through all .nc files (~30 - 40 years) for Solar Radiation and provide point based data.
#' @details for AOI it requires a "AOI_GPS.RDS" data frame with c("longitude","latitude") columns being saved in 
#'                            paste("~/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_",useCaseName, "/", Crop, "/raw", sep="") 
#'          for trial sites it requires a "compiled_fieldData.RDS" data frame with c("lon", "lat", "plantingDate", "harvestDate") being saved in 
#'                    paste("~/agwise-datacuration/dataops/datacuration/Data/useCase_",country, "_",useCaseName, "/", Crop, "/result", sep="")
#
#'
#' @param country country name
#' @param useCaseName use case name  name
#' @param Crop the name of the crop to be used in creating file name to write out the result.
#' @param AOI TRUE if the GPS are for prediction for the target area, FALSE otherwise, it is used to avoid overwriting the point data from the trial locations.
#' @param ID only when AOI  = FALSE, it is the column name Identifying the trial ID in compiled_fieldData.RDS
#'
#' @return
#' @examples extract_topography_pointdata(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", 
#' GPSdata = read.csv("~/agwise/AgWise_Data/fieldData_analytics/UseCase_Rwanda_RAB/result/aggregated_field_data.csv"))

extract_topography_pointdata <- function(country, useCaseName, Crop, AOI=FALSE, ID=NULL){
  
  if(AOI == TRUE){
    GPSdata <- readRDS(paste("~/agwise-datacuration/dataops/datacuration/Data/useCase_", country, "_",useCaseName, "/", Crop, "/result/AOI_GPS.RDS", sep=""))
    
    # GPSdata <- readRDS(paste("~/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_",useCaseName, "/", Crop, "/raw/AOI_GPS.RDS", sep=""))
    GPSdata <- unique(GPSdata[, c("longitude", "latitude")])
    GPSdata <- GPSdata[complete.cases(GPSdata), ]
  }else{
    GPSdata <- readRDS(paste("~/agwise-datacuration/dataops/datacuration/Data/useCase_",country, "_",useCaseName, "/", Crop, "/result/compiled_fieldData.RDS", sep=""))  
    GPSdata <- unique(GPSdata[, c("lon", "lat", ID)])
    GPSdata <- GPSdata[complete.cases(GPSdata), ]
    names(GPSdata) <- c("longitude", "latitude", "ID")
  }
  
  gpsPoints <- GPSdata
  gpsPoints$x <- as.numeric(gpsPoints$longitude)
  gpsPoints$y <- as.numeric(gpsPoints$latitude)
  gpsPoints <- gpsPoints[, c("x", "y")]
  
  pathin <- paste("~/agwise-datasourcing/dataops/datasourcing/Data/useCase_",country, "_", useCaseName,"/", Crop,"/" ,"/transform/Topography", sep="")
    
  listRaster <-list.files(path=pathin, pattern=".tif$")
  topoLayer <- terra::rast(paste(pathin, listRaster, sep="/"))
  # datatopo <- terra::extract(topoLayer, gpsPoints, xy = TRUE)
  datatopo <- terra::extract(topoLayer, gpsPoints, method='simple', cells=FALSE)
  datatopo <- subset(datatopo, select=-c(ID))
  topoData <- cbind(GPSdata, datatopo)
  
  countryShp <- geodata::gadm(country, level = 3, path='.')
  dd2 <- raster::extract(countryShp, gpsPoints)[, c("NAME_1", "NAME_2")]
  topoData$NAME_1 <- dd2$NAME_1
  topoData$NAME_2 <- dd2$NAME_2
  
  if(!is.null(ID)){
    # topoData <- topoData[, c("longitude", "latitude", "ID", "layer", "slope", "TPI", "TRI","NAME_1", "NAME_2")]
    colnames(topoData) <- c("longitude", "latitude", "ID" ,"altitude", "slope", "TPI", "TRI", "NAME_1", "NAME_2")
  }else{
    # topoData <- topoData[, c("longitude", "latitude", "layer", "slope", "TPI", "TRI","NAME_1", "NAME_2")]
    colnames(topoData) <- c("longitude", "latitude", "altitude", "slope", "TPI", "TRI", "NAME_1", "NAME_2")
  }
  
    
  pathOut1 <- paste("~/agwise-datasourcing/dataops/datasourcing/Data/useCase_", country, "_", useCaseName,"/", Crop, "/result/Topography", sep="")
  pathOut2 <- paste("~/agwise-potentialyield/dataops/potentialyield/Data/useCase_", country, "_", useCaseName,"/", Crop, "/raw/Topography", sep="")
  pathOut3 <- paste("~/agwise-responsefunctions/dataops/responsefunctions/Data/useCase_", country, "_", useCaseName,"/", Crop, "/raw/Topography", sep="")
  pathOut4 <- paste("~/agwise-datacuration/dataops/datacuration/Data/useCase_", country, "_", useCaseName,"/", Crop, "/raw/Topography", sep="")
    
    if (!dir.exists(pathOut1)){
    dir.create(file.path(pathOut1), recursive = TRUE)
  }
  
  if (!dir.exists(pathOut2)){
    dir.create(file.path(pathOut2), recursive = TRUE)
  }
  
  if (!dir.exists(pathOut3)){
    dir.create(file.path(pathOut3), recursive = TRUE)
  }
  
  if (!dir.exists(pathOut4)){
    dir.create(file.path(pathOut4), recursive = TRUE)
  }
    
  f_name <- ifelse(AOI == TRUE, "Topography_PointData_AOI.RDS", "Topography_PointData_trial.RDS")
  
  saveRDS(topoData, paste(pathOut1, f_name, sep="/"))
  saveRDS(topoData, paste(pathOut2, f_name, sep="/"))
  saveRDS(topoData, paste(pathOut3, f_name, sep="/"))
  saveRDS(topoData, paste(pathOut4, f_name, sep="/"))
  
  return(topoData)
}





