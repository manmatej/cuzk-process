
## ============================= lidR ==================================
# https://r-lidar.github.io/lidRbook/engine.html
# install.packages("sf")
# install.packages("terra")
# install.packages("gstat")
# install.packages("future")
# install.packages("MBA")

library(lidR)
library(sf)
library(terra)
library(gstat)
library(future)
library(MBA)

unzips<-r"(d:\DMR5G_CUZK_LAZ_OPEN_202306\las_class2\)"
setwd(unzips)

ctg <- readLAScatalog(unzips)
st_crs(ctg)<-5514
# plot(ctg)
# las_check(ctg)
# summary(ctg)

hd<-r"(d:\DMR5G_CUZK_LAZ_OPEN_202306\las_class2\tin_2m)"
dir.create(hd)
setwd(hd)

## tin
dtm <- rasterize_terrain(ctg, res=2, tin())
writeRaster(dtm,"DMR5G_2m_tin_open.img",overwrite=T)
plot(dtm,col = gray(1:50/50))
# plot_dtm3d(dtm, bg = "white")


plot(dtm[[1]],col = gray(1:50/50))
## tin - eliminate holes
dtm <- rasterize_terrain(ctg, res=2, tin(extrapolate = knnidw(k = 20, p = 2, rmax = 100)))
plot(dtm,col = gray(1:50/50))
dt<-do.call(mosaic,dtm)

writeRaster(dtm,r"(y:\CR\CZECH_GRIDS_1.0\00_inout_krovak_2m\DMR5G_2m_tin_open_elim_holes.img)",overwrite=T)
plot(dtm,col = gray(1:50/50))
# plot_dtm3d(dtm, bg = "white")



## testing ==================================================================
# prackovice <- clip_circle(ctg, x= -762595.74, y =-986323.41, radius = 2000)
# hd<-r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306_matej_testing\prackovice)"
# vosak <- clip_circle(ctg, x= -731639.81, y =-954457.37, radius = 2000)
# hd<-r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306_matej_testing\vosak)"
# dir.create(hd)
# setwd(hd)

milada<-clip_circle(ctg, x= -767455.2, y =-975922.9, radius = 2000)
hd<-r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306_matej_testing\milada)"
dir.create(hd)
setwd(hd)



# test<-prackovice
# test<-vosak
test<-milada

## tin
dtm <- rasterize_terrain(test, res=2, tin(extrapolate =  knnidw(k = 5, p = 2, rmax = 50)))
dtm1 <- rasterize_terrain(test, res=2, tin(extrapolate = knnidw(k = 20, p = 2, rmax = 100)))

r<-dtm-dtm1
summary(r)
plot(r)

library(terra)

# Assume r is your SpatRaster of differences
# Make a diverging color palette (e.g., blue-white-red)
col_fun <- colorRampPalette(c("blue", "white", "red"))

# Define breaks: centered at zero, to highlight changes
max_abs <- max(abs(min(values(r), na.rm = TRUE)), abs(max(values(r), na.rm = TRUE)))
breaks <- seq(-max_abs, max_abs, length.out = 100)

# Plot with custom colors
plot(r, col = col_fun(length(breaks)-1), breaks = breaks, main="Difference (dtm - dtm1)")




plot(dtm,col = gray(1:50/50))
plot_dtm3d(dtm, bg = "white")
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
