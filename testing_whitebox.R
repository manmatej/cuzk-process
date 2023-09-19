

## ============================== whitebox tools ==============================
install.packages("whitebox", repos="http://R-Forge.R-project.org")
whitebox::wbt_init()

library(whitebox)
wbt_version()

# LAZ and LAS are not supported in wbt, therefore convet to "zlidar"
wbt_las_to_zlidar(
  inputs = "ZACL39.las",
  outdir = ".")

# try to produce raster from pointcloud
output="CUZK_LIDAR_CZ.tif"

r<-wbt_lidar_tin_gridding(
  input="ZACL39.las",
  output = output,
  parameter = "elevation",
  returns = "all",
  resolution = 1000)


