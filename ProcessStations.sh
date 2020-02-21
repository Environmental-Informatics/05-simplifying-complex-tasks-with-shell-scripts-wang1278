#!/bin/bash
# This program identifies stations with high elevation and copy them to another folder. Then it plot all stations while highlight stations with high elevation and converts the figure into multiple image formats.

# Linji Wang
# 02/21/20

# load the gmt module for plotting
module load gmt

# Check if the directory "HigherElevation" Exists. Create it if not.
if [ ! -d ./HigherElevation ]
then
mkdir HigherElevation
echo directory \"HigherElevation\" not found, creating it.
fi

# Look for station that has elevation equal or greater than 200 ft and copy it to "HigherElevation" directoy if found.
for file in ./StationData/*
do
	path=$(awk '/Altitude/ && $NF >= 200 {print FILENAME}' $file)
	if [ -n "$path" ]
	then cp $path ./HigherElevation
	fi
done
echo Station files with elevation higher than 200 are copied to directory \"HigherElevation\".

# Getting long/lat from all station files and store them into one file for plotting.
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' StationData/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStation.xy

# Getting long/lat from higher elevation station files and store them into one file for plotting.
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list
awk '/Latitude/ {print $NF}' HigherElevation/Station_*.txt > HELat.list
paste HELong.list HELat.list > HEStation.xy

# Draws rivers filled in blue, lakes filled in blue, and orange boundaries
gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Dh -Ia/blue -Na/orange -P -Sblue -K -V > SoilMoistureStations.ps
# Add black circles for all station locations
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
# Add smaller red circles for all higher elevation stations
gmt psxy HEStation.xy -J -R -Sc0.1 -Gred -O -V >> SoilMoistureStations.ps

# Convert PS image files to EPSI files
ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi

# Convert EPSI files to TIF files with 150 dps
convert -density 150 SoilMoistureStations.epsi SoilMoistureStations.tif

echo Program excute complete.


