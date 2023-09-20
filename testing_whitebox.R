

## ============================== whitebox tools ==============================
install.packages("whitebox")
whitebox::wbt_init()
whitebox::install_whitebox()
  
library(whitebox)
wbt_version()

# produce raster from pointcloud tiles
input1 = "d:\\laz"
input2 = "d:\\Git\\cuzk-process\\laz"
input3 = "c:/Users/matej.man/Downloads/laz/"

output="d:\\Git\\cuzk-process\\CUZK_LIDAR_CZ_mosaic.tif"

p1<-"ZACL39.laz"
p2<-"ZACL29.laz"


wbt_lidar_tin_gridding(
  input=input1,
  output = "c:/Users/matej.man/Downloads/laz/fin.tif",
  parameter = "elevation",
  returns = "all",
  resolution = 10)

wbt_lidar_tin_gridding(
  input=input2,
  output = "c:/Users/matej.man/Downloads/laz/fin.tif",
  parameter = "elevation",
  returns = "all",
  resolution = 10)

wbt_lidar_tin_gridding(
  input=input3,
  output = "c:/Users/matej.man/Downloads/laz/fin.tif",
  parameter = "elevation",
  returns = "all",
  resolution = 10)

setwd(input2)
wbt_lidar_tin_gridding(
  input=".",
  output = "c:/Users/matej.man/Downloads/laz/fin.tif",
  parameter = "elevation",
  returns = "all",
  resolution = 10)
