library(sp)
library(fields)

summ.list <- list()
for(i in 1981:2014){
  load(paste0('tempSumm_',i,'.Rdata'))
  summ.list[[paste0('yr_',i)]] <- data.frame(Year=i,
                                             lat=as.numeric(gsub('X\\.?\\d+\\.?\\d+_\\.?', '', names(overall.mean))),
                                             lon=as.numeric(gsub('X\\.?|_\\.?\\d+\\.?\\d+', '', names(overall.mean)))*-1,
                                             mean=overall.mean,
                                             min=overall.min,
                                             max=overall.max,
                                             annualRange=overall.annual.range,
                                             summMean=overall.summer.mean)
}
summ.df <- do.call('rbind', summ.list)
rownames(summ.df) <- NULL

sample.sites <- read.csv('SitePoints.csv')
site.coords <- subset(sample.sites, siteID != '-')[,c('Longitude', 'Latitude')]
pixel.coords <- coordinates(summ.list[['yr_1981']][,c('lon', 'lat')])

#create new sampling points, shifted to the center of the pixel they fall on, or to the near pixel in case that one is NA
site.coords.shifted<-vector()
#loop cycling through sampling points
for (p in 1:nrow(site.coords)){
  #geodesic distances
  distances <- rdist.earth(coordinates(site.coords[p,]), pixel.coords, miles=FALSE)
  #coordinates of the pixel that is at shorter distance 
  shifted.coords <- pixel.coords[which.min(distances),]
  site.coords.shifted <- rbind(site.coords.shifted, shifted.coords)
}
sample.sites2 <- cbind(subset(sample.sites, siteID != '-'), site.coords.shifted)
summ.df.sites <- merge(summ.df, sample.sites2)
summ.df.sites2 <- summ.df.sites[order(summ.df.sites$siteID, -summ.df.sites$Year),]
summ.df.sites3 <- summ.df.sites2[,c('Year','siteID','mean','max','min','annualRange','summMean')]

filename <- 'SST_bySite.csv'
write.csv(summ.df.sites3, filename, row.names = FALSE, quote = FALSE)
