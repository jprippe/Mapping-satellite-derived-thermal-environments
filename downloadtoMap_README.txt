###=======================
This README walks through how to download and analyse OISST daily sea surface temperature data for the Caribbean region, as an example, and visualize  summary parameters in a map figure.
###=======================

### INSTALLATIONS ###
Before you begin, make sure that the netcdf software library is installed and loaded in your computing environment. This is required for the rerddap package to work in R.
#####################

1. Generate and execute a job script to download annual datasets from ERDDAP

# The following command generates a job file for downloading each of the 37 years between 1982-2018 individually. This allows the process to be parallelized for faster downloading.

>erddap_Carib
for i in `seq 1982 2018`; do 
echo "Rscript --vanilla erddap_download_TACC.R ncdcOisst2Agg_LonPM180 https://coastwatch.pfeg.noaa.gov/erddap/ 7.5 30.5 -98.5 -58.5 sst $i-01-01 $i-12-31" >>erddap_Carib; 
done

# The order of arguments is as follows:
# datasetID (found on the ERDDAP website)
# ERDDAP url
# ymin (latitude)
# ymax (latitude)
# xmin (longitude)
# xmax (longitude)
# variable ID (found on "data" page for the specified dataset)
# start date (YYYY-MM-DD)
# end date (YYYY-MM-DD)

# Execute all commands in the resulting file. Individual .Rda files will be output to the working directory for each of the years specified.


2. Calculate summary statistics for every pixel in the dataset extent

# The following command generates a job file to calculate various summary statistics for each year individually and saves the resulting datasets to individual .Rdata files.

>enviroSumm_Carib
for i in `seq 1982 2018`; do 
echo "Rscript --vanilla enviroSumm_TACC.R $i" >>enviroSumm_Carib; 
done

# Note: The advantage of splitting the analyses across years is twofold: (1) allows the process to be parallelized as above (2) for large datasets (e.g., the full Caribbean region used in this example), R will often crash if data objects are too large, so spreading across smaller data objects can avoid this issue.

# Execute all commands in the resulting file. Individual .Rdata files will be output to the working directory for each of the years specified.


3. Calculate more derived summary statistics (e.g., thermal stress, slope, etc.) and display as a map layer.

# Execute enviroMap.R script in preferred R environment.

# Note: This script makes use of the GSHHS high-resolution coastline map layer (downloadable here: https://www.ngdc.noaa.gov/mgg/shorelines/). However, any map layer will work, such as those available in the maptools package, as long as the projection matches the environmental dataset (-180-180 vs. 0-360 longitude).


