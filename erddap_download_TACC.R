###~~~~~~~~~~~~~~~~~~~~
# This code is adapted directly from the vignette written by Rob Schlegel and AJ Smit 
# https://cran.r-project.org/web/packages/heatwaveR/vignettes/OISST_preparation.html
# https://github.com/robwschlegel/heatwaveR/
###~~~~~~~~~~~~~~~~~~~~

# These are the commands to run on TACC for each dataset:
# echo "Rscript --vanilla erddap_download.R" > erddap
# ls5_launcher_creator.py -j erddap -n erddap -t 00:30:00 -w 1 -a tagmap -e jpr6mg@gmail.com -q normal
# sbatch erddap.slurm

# May need to load the netcdf module in TACC before installing rerddap package

#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)!=9) {
  stop("Dataset ID, url, ymin, ymax, xmin, xmax, variable ID, start date and end date must be supplied in that order.\n", call.=FALSE)
}

# The two packages we will need
#devtools::install_github("tidyverse/tidyverse")
#devtools::install_github("ropensci/rerddap")

# Load the packages once they have been downloaded and installed
library(tidyverse)
library(rerddap)

########################
datasetid = args[1]
#datasetid = "ncdcOisst2Agg_LonPM180"
url = args[2]
#url = "https://coastwatch.pfeg.noaa.gov/erddap/"
latitude.range = c(as.numeric(args[3]), as.numeric(args[4]))
#latitude.range = c(7.5, 30.5)
longitude.range = c(as.numeric(args[5]), as.numeric(args[6]))
#longitude.range = c(-98.5, -58.5)
var.id = args[7]
#var.id = "sst"
start.date = args[8]
#start.date = "1982-01-01"
end.date = args[9]
#end.date = "1986-12-31"
########################

# The information for the dataset
rerddap::info(datasetid = datasetid, url = url)

### IMPORTANT: ###
# If the dataset includes an altitude dimension, it needs to be specified in the following function (e.g., zlev below). 
# If not, the zlev line should be deleted.
#######
data_sub <- function(time_df){
  data_res <- griddap(x = datasetid, 
                      url = url, 
                      time = c(time_df$start, time_df$end), 
                      zlev = c(0, 0),
                      latitude = latitude.range,
                      longitude = longitude.range,
                      fields = var.id)$data %>% 
    mutate(time = as.Date(str_remove(time, "T00:00:00Z"))) %>% 
    rename(t = time, var = all_of(var.id)) %>% 
    select(lon, lat, t, var) %>% 
    na.omit()
}

# Date download range by start and end dates per year (faster to download as one full period, rather than a sequence of years)
dl_years <- data.frame(date_index = 1,
                       start = as.Date(start.date),
                       end = as.Date(end.date))

# Download all of the data with one nested request
# The time this takes will vary greatly based on connection speed
satellite_data <- dl_years %>% 
  group_by(date_index) %>% 
  group_modify(~data_sub(.x)) %>% 
  ungroup() %>% 
  select(lon, lat, t, var)

# Save the data as an .Rda file as it has a much better compression rate than .RData
saveRDS(satellite_data, file = paste0(args[1],"_",args[8],"_",args[9],".Rda"))
#write.table(satellite_data, file = paste0(args[1],"_",args[8],"_",args[9],".txt"), sep = "\t")
