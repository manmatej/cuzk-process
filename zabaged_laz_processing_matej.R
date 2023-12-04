
## ============================= lidR ==================================
# https://r-lidar.github.io/lidRbook/engine.html
# install.packages("sf")
# install.packages("terra")
# install.packages("gstat")
# install.packages("future")
# install.packages("MBA")
# devtools::install_github("Jean-Romain/rlas", dependencies=TRUE)
# devtools::install_github("Jean-Romain/lidR", dependencies=TRUE)


library(lidR)
library(sf)
library(terra)
library(gstat)
library(future)
library(MBA)

## production ===============================================================

unzips<-r"(d:\Man\DMR5G_CUZK_LAZ_OPEN_202306\)"
setwd(unzips)
get_lidr_threads()
set_lidr_threads(0L)

library(future)
plan(multisession)

ctg <- readLAScatalog(unzips)
st_crs(ctg)<-5514
rslt<-r"(d:\Man\DMR5G_CUZK_LAZ_OPEN_202306_rslt)"
dir.create(rslt)
opt_output_files(ctg)<-paste0(rslt, "/{*}_tin")
dtm <- rasterize_terrain(ctg, res=2, tin())
writeRaster(dtm, r"(d:\Man\dtm_2m_tin1.tif)",overwrite=T)

getwd()
st_write(ctg$geometry,"tile_catalog.gpkg")

## testing ==================================================================
# prackovice <- clip_circle(ctg, x= -762595.74, y =-986323.41, radius = 2000)
# hd<-r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306_matej_testing\prackovice)"
vosak <- clip_circle(ctg, x= -731639.81, y =-954457.37, radius = 2000)
hd<-r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306_matej_testing\vosak)"
dir.create(hd)
setwd(hd)

# test<-prackovice
test<-vosak

## tin
dtm <- rasterize_terrain(test, res=2, tin())
plot(dtm,col = gray(1:50/50))
# plot_dtm3d(dtm, bg = "white")
writeRaster(dtm,"dtm_2m_tin.tif",overwrite=T)


## MBA
# mba is our function factory
mba <- function(n = 1, m = 1, h = 8, extend = TRUE, overwrite=TRUE) {
  # f is created inside mba and receive the ground points in a LAS (gnd)
  # and the location where to compute the interpolation (where) 
  f <- function(gnd, where,overwrite=TRUE) {
    # computation of the interpolation (see the documentation of MBA package)
    res <- MBA::mba.points(gnd@data, where, n, m , h, extend,overwrite=TRUE)
    return(res$xyz.est[,3])
  }
  
  # f is a function but we can set compatible classes. Here it is an
  # algorithm for DTM 
  f <- plugin_dtm(f)
  return(f)
}

dtm1 <- rasterize_terrain(test, res=2, algorithm = mba(h=15),overwrite=TRUE)
writeRaster(dtm1,"dtm_2m_mbah15.tif",overwrite=T)
plot(dtm1, col = gray(1:50/50))
# plot_dtm3d(dtm1, bg = "white")



# compare to original 2019 DMR5G downloaded from CUZK
library(terra)
# poi<-st_point(c(-762595.74, -986323.41)) # prackovice
poi<-st_point(c(-731639.81, -954457.37)) # vosak

poi<-st_sfc(poi,crs=5514)
roi<-st_buffer(poi,2000)
v<-vect(roi)

orig<-rast(r"(y:\CR\DMR5G_2019_SAGA\dmr5g_2019s.sdat)")
r<-crop(orig,v)
crs(r)<-crs(v)
rr<-mask(r,v)
writeRaster(rr,"origo2019.tif")







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



