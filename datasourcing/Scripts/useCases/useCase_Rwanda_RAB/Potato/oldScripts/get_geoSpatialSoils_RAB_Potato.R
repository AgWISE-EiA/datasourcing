

#################################################################################################################
## source "get_geo-SpatialSoils.R" function and execute it for Rwanda RAB use case
#################################################################################################################
source("~/agwise-datasourcing/dataops/datasourcing/Scripts/generic/get_geoSpatialSoils.R")


#################################################################################################################
## choose data source and crop the global layers to the target country shape file. 
#################################################################################################################

crop_geoSpatial_soil(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", dataSource= "iSDA", overwrite = TRUE)
crop_geoSpatial_soil(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", dataSource= "soilGrids", overwrite = TRUE)


#################################################################################################################
## add derived soil variables like soil hydraulics data 
#################################################################################################################

transform_soils_data(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", resFactor=1, overwrite = TRUE)


#################################################################################################################
### extracting soil geo-spatial data for GPS locations (this is essential to get for location we have field/survey data)
#################################################################################################################

RAB_potato_soil <- extract_soil_pointdata(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", AOI = FALSE, ID = "TLID", profile = FALSE)

#################################################################################################################
## extracting soil geo-spatial data for GPS locations for predictions, for AOI
#################################################################################################################
RAB_potato_soil_AOI <- extract_soil_pointdata(country = "Rwanda", useCaseName = "RAB", Crop = "Potato", AOI = TRUE, ID=NULL)









