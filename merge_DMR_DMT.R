
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
library(stringr)

dtm.f<-list.files(r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306\las_class2\)",pattern="*.las$")
dtm.ff<-list.files(r"(y:\CR\DMR5G_CUZK_LAZ_OPEN_202306\las_class2\)",pattern="*.las$",full.names = T)
dsm.f<-list.files(r"(y:\CR\DMP1G_CUZK_LAZ_OPEN_202306\)",pattern="*.laz$")
dsm.ff<-list.files(r"(y:\CR\DMP1G_CUZK_LAZ_OPEN_202306\)",pattern="*.laz$",full.names = T)

dtm.n<-strsplit(dtm.f,"_")
dtm.n<-lapply(dtm.n, "[",1)
dtm.n.dot<-paste0(".",dtm.n,".")

dsm.n<-str_remove(dsm.f,".laz")
dsm.n.dot<-paste0(".",dsm.n,".")

setdiff(dsm.n,dtm.n)
setdiff(dtm.n,dsm.n)

nms<-unique(dsm.n,dtm.n)
nms.dot<-paste0(".",nms,".")

setwd(r"(y:\CR\DMP1G_DMR5G_CUZK_LAZ_OPEN_202306_merge\)")

for (i in 1:length(nms)){
  tryCatch({message(paste0("Processing file ",i," out of ",length(nms)))
    nam<-nms.dot[i]
    nn<-nms[i]
    dsm.t<-dsm.ff[grepl(nam,dsm.n.dot,fixed=T)]
    dtm.t<-dtm.ff[grepl(nam,dtm.n.dot,fixed=T)]
    lcat<-readLAScatalog(c(dsm.t,dtm.t))
    opt_output_files(lcat) <- nn
    opt_chunk_size(lcat) <- 0
    opt_chunk_buffer(lcat) <- 10
    s<-catalog_retile(lcat)},error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

mrg<-readLAScatalog(".")
mrg
plot(mrg)
