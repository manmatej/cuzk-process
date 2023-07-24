loc<-"\\\\ibot.cas.cz\\Public\\Freenas\\y_gis_data\\CR\\DMR5G_CUZK_LAZ_OPEN_202306\\"
zips<-list.files(loc,pattern = "*.zip$",full.names = T) # list paths to all zip files in current directory

# unzips<-"d:\\DMR5G_CUZK_LAZ_OPEN_202306_unzip"
unzips<-tempdir()
# dir.create(unzips)
setwd(unzips)


for (i in 1:length(zips[1:10])){
  unzip(zips[i],exdir=unzips)  # unzip your file 
}

## ============================== whitebox tools ==============================
# install.packages("whitebox", repos="http://R-Forge.R-project.org")
# whitebox::wbt_init()

library(whitebox)

setwd(unzips)
fil<-list.files(unzips,full.names = T,pattern = "*.laz$")
# f<-paste(fil[1:10],collapse = ",")
input<-fil[1]
output="CUZK_LIDAR_CZ.las"

r<-wbt_lidar_tin_gridding(
  input,
  output = output,
  parameter = "elevation",
  returns = "all",
  resolution = 100)



wbt_lidar_join(inputs = fil, output = "CUZK_LIDAR_CZ_merge.las")
# r<-wbt_lidar_idw_interpolation(input =  f,resolution = 1000) # for one scene CUZK it run more than 3 days, not finished, aborted. 





## ============================= lidR ==================================
# https://r-lidar.github.io/lidRbook/engine.html


library(devtools)
install_github("r-lidar/lidR")
install_github("r-lidar/rlas")
library(lidR)
library(terra)

setwd(unzips)

ctg <- readLAScatalog(unzips)
plot(ctg)
las_check(ctg)

roi <- clip_circle(ctg, x = -954742, y = -730752, radius = 100)
plot(roi, bg = "white", size = 4)


# in memmory
dtm <- rasterize_terrain(ctg, 2, tin(), pkg = "terra")
dtm_prod <- terra::terrain(dtm, v = c("slope", "aspect"), unit = "radians")
dtm_hillshade <- terra::shade(slope = dtm_prod$slope, aspect = dtm_prod$aspect)
plot(dtm_hillshade, col = gray(0:50/50), legend = FALSE)

# on disk
opt_output_files(ctg) <- opt_output_files(ctg) <- paste0(tempdir(), "/{*}_dtm")
dtm <- rasterize_terrain(ctg, 1, tin())
dtm