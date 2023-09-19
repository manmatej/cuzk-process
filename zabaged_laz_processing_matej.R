loc<-"\\\\ibot.cas.cz\\Public\\Freenas\\y_gis_data\\CR\\DMR5G_CUZK_LAZ_OPEN_202306\\"
zips<-list.files(loc,pattern = "*.zip$",full.names = T) # list paths to all zip files in current directory

unzips<-"d:\\DMR5G_CUZK_LAZ_OPEN_202306_unzip"
# unzips<-tempdir()
dir.create(unzips)
setwd(unzips)


for (i in 1:length(zips)){
  unzip(zips[i],exdir=unzips)  # unzip your file 
}

fil<-list.files(unzips,full.names = T,pattern = "*.laz$")

## ============================= lidR ==================================
# https://r-lidar.github.io/lidRbook/engine.html


# install.packages("sf")
# install.packages("terra")
# install.packages("gstat")
# install.packages("future")

library(lidR)
library(sf)
library(terra)
library(gstat)
library(future)

setwd(unzips)

ctg <- readLAScatalog(unzips)
st_crs(ctg)<-5514
plot(ctg)
las_check(ctg)
summary(ctg)





opt_output_files(ctg)<- paste0("d:\\DMR5G_CUZK_LAZ_OPEN_202306_lasCTG", "/{XCENTER}_{YCENTER}_{ID}")
cg<-classify_ground(ctg, algorithm = pmf(ws = 5, th = 3))
dtm <- rasterize_terrain(cg, res=10, tin())
writeRaster(dtm,"dtm_10m.tif")
plot(dtm)
















## ============================== whitebox tools ==============================
# to mi nefunguje...
install.packages("whitebox", repos="http://R-Forge.R-project.org")
whitebox::wbt_init()

library(whitebox)
wbt_version()
setwd("d://Git/cuzk-process/")

unzips_zlidar<-"d:\\DMR5G_CUZK_LAZ_OPEN_202306_zlidar"
dir.create(unzips_zlidar,showWarnings=F)


library(lidR)
ly<-readLAS("ZACL39.laz")
writeLAS(ly,"ZACL39.las")

wbt_las_to_zlidar(
  inputs = "ZACL39.las",
  outdir = unzips_zlidar)


output="CUZK_LIDAR_CZ.tif"

r<-wbt_lidar_tin_gridding(
  input="ZACL39.las",
  output = output,
  parameter = "elevation",
  returns = "all",
  resolution = 1000) # run sooo long. Why? In saga-gis few second.  

wbt_lidar_join(inputs = fil, output = "CUZK_LIDAR_CZ_merge.las")
# r<-wbt_lidar_idw_interpolation(input =  f,resolution = 1000) # for one scene CUZK it run more than 3 days, not finished, aborted. 



