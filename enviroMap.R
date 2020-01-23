library(vegan)
library(maptools)
library(dplyr)
library(ggplot2)
library(raster)
library(xts)

summ.list <- list()
month.clim <- list()
bleaching.hotspots <- list()
for(i in 1982:2018){
  load(paste0('./tempSumm_',i,'.Rdata'))
  summ.list[[paste0('yr_',i)]] <- data.frame(mean=overall.mean,min=overall.min,max=overall.max,
                                             annualRange=overall.annual.range,monRange=overall.monthly.range,weekRange=overall.weekly.range,
                                             summMean=overall.summer.mean)
  month.clim[[paste0('yr_',i)]] <- monthly.mean
}
all.avg <- data.frame(plyr::aaply(plyr::laply(summ.list, as.matrix), c(2, 3), mean))

# Calculate monthly climatology for every pixel for heat stress metrics (NOAA CRW uses 1985-2012 for their climatology)
month.clim.xts <- month.clim$yr_1985
for(i in 1986:2012){month.clim.xts <- rbind(month.clim.xts,month.clim[[paste0('yr_',i)]])}
mcx <- data.frame(month.clim.xts)
mcx$month <- substr(rownames(mcx),6,7)
monthly.climatology <- mcx %>% group_by(month) %>% summarise_each(mean)
monthly.climatology <- monthly.climatology[,-1]

# Hottest and coldest month averages
mean.hottest.month <- apply(monthly.climatology,2,max)
mean.coldest.month <- apply(monthly.climatology,2,min)
which.hottest.month <- apply(monthly.climatology,2,which.max)
which.coldest.month <- apply(monthly.climatology,2,which.min)

# Bleaching hotspots from http://coralreefwatch.noaa.gov/satellite/methodology/methodology.php#hotspot
bleaching.hotspots.over1 <- list()
for(i in 1982:2018){
  load(paste0('./tempSumm_',i,'.Rdata'))
  tm.df <- data.frame(apply(xc, 1, function(x) x-mean.hottest.month))
  bleaching.hotspots.over1[[paste0('yr_',i)]] <- rowSums(tm.df>=1)
}
all.avg$avg.stress <- colMeans(do.call('rbind', bleaching.hotspots.over1))

# Calculate the slope in annual mean for each pixel
lm.fun <- function(x,times){
  if(any(is.na(x))){NA}
  else{
    lm(x~times)$coefficients[2]
  }
}
pix.means <- data.frame(summ.list[['yr_1982']]$mean)
for(i in 1983:2018){pix.means <- cbind(pix.means,summ.list[[paste0('yr_',i)]]$mean)}
all.avg$slope <- apply(pix.means, 1, function(x) lm.fun(x,c(1982:2018)))

# Use principal component analysis to evaluate multivariate patterns across the seascape
pca.dat <- rda(all.avg, scale = T)
pca.coords <- pca.dat$CA$u
pca.plot.data <- data.frame(lon=as.numeric(gsub('X\\.?|_\\.?\\d+\\.?\\d+','',rownames(all.avg))), 
                            lat=as.numeric(gsub('X\\.?\\d+\\.?\\d+_\\.?','',rownames(all.avg)))*-1, 
                            var=pca.coords[,1])

save(all.avg, pca.plot.data, file='finalData.Rdata')


# Mapping -----------------------------------------------------------------

#install.packages('gpclib', type='source')
if (!rgeosStatus()) gpclibPermit()
gshhs.f.b <- './gshhg-bin-2.3.6/gshhs_f.b'
sf1 <- getRgshhsMap(gshhs.f.b, xlim = c(-100, -50), ylim = c(5, 35)) %>%
  fortify()

#load('finalData.Rdata')

#~~~~~~~~~
# Specify the data layer you want to project (use colnames(all.avg) to see your options)
data.layer <- 'mean'
#~~~~~~~~~

all.avg2 <- data.frame(lon=as.numeric(gsub('X\\.?|_\\.?\\d+\\.?\\d+','',rownames(all.avg)))*-1, 
                       lat=as.numeric(gsub('X\\.?\\d+\\.?\\d+_\\.?','',rownames(all.avg))), 
                       var=all.avg[,data.layer])

ggplot() + 
  geom_tile(data = all.avg2, aes(x=lon, y=lat, fill=var, width=0.3, height=0.3))+
  geom_polygon(data = sf1, aes(x=long, y = lat, group = group), fill = 'grey70', color='black', lwd = 0.1) +
  theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  coord_fixed(ratio=1.1, xlim = c(-98.5,-58.5), ylim = c(7.5,30.5), expand = 0)+
  scale_fill_gradient2(low = 'dodgerblue', high = 'red', mid = 'white', midpoint = mean(all.avg2$var))


