# Q <- read.csv("~/agwise/AgWise_Data/potential_yield/UseCase_Rwanda_RAB/Maize/raw/data_Camilo/Tmax.csv")

#################################################################################################################
## source "get_rain_temp_summary.R" function and get rain and temperature summary data 
#################################################################################################################
source("~/agwise-datasourcing/dataops/datasourcing/Scripts/generic/get_geoSpatialTemperature_MC.R")



#################################################################################################################
## get daily TMax and Tmin
## for trial sites from AgEra5
#################################################################################################################
trial_point_Tmax_AgEra <- get_temp_pointData(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", AOI = FALSE,
                                             overwrite = TRUE, Planting_month_date = NULL,  Harvest_month_date = NULL, 
                                            jobs=10, dataSource = "AgEra", varName = "Tmax", ID="TLID")


trial_point_Tmin_AgEra <- get_temp_pointData(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", AOI = FALSE, 
                                             overwrite = TRUE,Planting_month_date = NULL,  Harvest_month_date = NULL, 
                                             jobs=10, dataSource = "AgEra", varName = "Tmin", ID="TLID")

#################################################################################################################
## get daily TMax and Tmin 
## for AOI from AgEra5 :: 
#################################################################################################################

AOI_point_Tmax_AgEra5 <- get_temp_pointData(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", AOI = TRUE,
                                   overwrite = TRUE, Planting_month_date = "02-05", 
                                   Harvest_month_date = "06-05", jobs=10, dataSource = "AgEra", varName = "Tmax", ID = NULL)


AOI_point_Tmin_AgEra5 <- get_temp_pointData(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", AOI = TRUE,
                                    overwrite = TRUE, Planting_month_date = "02-05", 
                                    Harvest_month_date = "06-05", jobs=10, dataSource = "AgEra", varName = "Tmin", ID = NULL)

#################################################################################################################
## get Tmin and Tmax summaries
## for AOI from AgEra
#################################################################################################################

AOI_Tmax_summary_p1 <- get_temp_pointSummarydata(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", 
                                    AOI = TRUE, overwrite = TRUE, Planting_month_date = "08-08", 
                                    Harvest_month_date = "12-08", jobs=10,
                                    dataSource = "AgEra", varName = "Tmax")


AOI_Tmin_summary_p1 <- get_temp_pointSummarydata(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", 
                                    AOI = TRUE, overwrite = TRUE, Planting_month_date = "08-08", 
                                    Harvest_month_date = "12-08", jobs=10,
                                    dataSource = "AgEra", varName = "Tmin")


#################################################################################################################
## get Tmin and Tmax summaries
## for trial sites from AgEra
#################################################################################################################

trial_Tmax_summary_p1 <- get_temp_pointSummarydata(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", 
                                      AOI = FALSE, overwrite = TRUE, Planting_month_date = NULL, 
                                      Harvest_month_date = NULL, jobs=10,
                                      dataSource = "AgEra", varName = "Tmax", ID="TLID")


trial_Tmin_summary_p1 <- get_temp_pointSummarydata(country = "Rwanda",  useCaseName = "RAB", Crop = "Maize", 
                                      AOI = FALSE, overwrite = TRUE, Planting_month_date = NULL, 
                                      Harvest_month_date = NULL, jobs=10,
                                      dataSource = "AgEra", varName = "Tmin", ID="TLID")



