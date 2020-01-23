# Mapping-satellite-derived-thermal-environments

JP Rippe, jpr6mg@gmail.com

This procedure takes advantage of the ERDDAP data server, which provides access to many gridded scientific datasets in one consistent location. Downloading geographic and/or temporal subsets of satellite-derived environmental data is often a considerable challenge. The erddap_download_TACC.R script included in this repository offers a relatively straightforward method for doing so using code directly adapted from that of Rob Schlegel (https://robwschlegel.github.io/heatwaveR/articles/OISST_preparation.html). The subsequent scripts (enviroSumm_TACC.R and enviroMap.R) perform various statistical analyses to summarize the raw data across the data range and visualize selected parameters in a map.

This repository includes the scripts needed to process the data and generate a map figure as well as a text walkthrough (downloadtoMap_README.txt). This is written specifically for implementation on the Texas Advanced Computing Center but can be modified without much trouble for use in any computing environment.

### Example output:

_Caribbean - Mean SST (1982-2018)_
![Caribbean - Mean SST (1982-2018)](/meanSST_Carib.png)
