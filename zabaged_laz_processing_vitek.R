#install.packages("lidR")
library(lidR)
library(terra)


setwd("D:/kasparvit/Documents/URBCLIM/Ostrava/data/OSTR80/")


### ---------- classification

# ground (2)
# high vegetation (5)
# building (6)

ground <-  readLAS("OSTR80.laz",select = "cxyz", filter = "-keep_class 2")
vegetation <-  readLAS("OSTR80.laz",select = "ncxyz", filter = "-keep_class 5")
building <-  readLAS("OSTR80.laz",select = "ncxyz", filter = "-keep_class 6")

hist(ground$Z)

#readLAS(filter = "-help")



### ------------ create DTM

dtm_tin <- rasterize_terrain(ground, res = 5, algorithm = tin()) # https://r-lidar.github.io/lidRbook/dtm.html
#dtm_tin_10 <- rasterize_terrain(ground, res = 10, algorithm = tin())


### -------------- normalize point cloud

# chm

chm_las <- normalize_height(vegetation, knnidw(),dtm = dtm_tin) # https://r-lidar.github.io/lidRbook/norm.html

# tin pomalejsi nez idw, statistics stejne
# rychlejsi a presnejsi normalizovat z dtm nez ground points

hist(chm_las$Z)
summary(chm_las$Z)

# filter z below 0 and above 50

chm_las <- filter_poi (chm_las, Z >= 0 & Z <= 50)

# bhm

bhm_las <- normalize_height(building, knnidw(),dtm = dtm_tin) # https://r-lidar.github.io/lidRbook/norm.html

# filter z below 0 

bhm_las <- filter_poi (bhm_las, Z >= 0)

hist(bhm_las$Z)
summary(bhm_las$Z)

## point cloud density



#### ---- create CHM/BHM raster

## ! nutne si pohrat s interpolacni metodou, bud vytvari pits(gaps) nebo spojuje (tringulaci) jine povrchy 

colnames(chm_las@data)[4] <- "ReturnNumber"
chm <- rasterize_canopy(chm_las, res = 1, algorithm = dsmtin(max_edge = 8))

writeRaster(chm,"chm_1m.tif",overwrite=TRUE)

colnames(bhm_las@data)[4] <- "ReturnNumber"
bhm <- rasterize_canopy(bhm_las, res = 1, algorithm = p2r(subcircle = 0.2))

writeRaster(bhm,"bhm_1m.tif",overwrite=TRUE)


