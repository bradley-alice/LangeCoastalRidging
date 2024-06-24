# LangeCoastalRidging

Project: Grounded Ridge Detection and Characterization along the Alaskan Arctic Coastline using ICESat-2 Surface Height Retrievals

Project Description: This repository contains code used to process ICESat-2 data to identify grounded ridges in satellite specific tracks across the Alaskan Arctic coastline. Further description of methods is contained in the publication that this code supports. 

Code Description:

ProcessingToDataset.m is the initial code which takes each individual ICESat-2 file, processed using the University of Maryland Ridge Detection Algorithm, and compiles it together into a data table. It also tests whether each track intersects the coastline and adds another column containing either ‘yes’, or ‘NA’ depending on the intersection status. This file splits the tracks into two geographic areas which we use in this analysis following the Chukchi and Beaufort Sea boundaries along the coastline. 

BulkTrackProcessing.m is the main branch of code which uses the dataset compiled in ProcessingToDataset.m and spits out a figure for each pass containing the depth estimates and bathymetry. In this code, the following functions are used: 

	distance_sparce.m calculates the distance of each measurement location to the coastline. 
	This uses the Coastline2021 shapefile, which has a trace of the coastline of northern Alaska in lat/lon. 

	fdd_thickness.m finds the expected ice thickness for any date using two different freezing degree day models. 
	This uses heightBeau.mat and heightChuk.mat which contain calculated FDD values for several sites. 
 	THESE FILES ARE TOO LARGE TO UPLOAD TO GITHUB: ACCESS THEM AT https://drive.google.com/file/d/188RPfbkj1gFux0DO-Gott_XKigbyJI-w/view?usp=sharing AND https://drive.google.com/file/d/1z-2cGIWuuFdISH0zb3VIl7Rx-q9ynFyZ/view?usp=sharing

	bathymetry_latlon_grid.mat and GEBCO_AlaskaCoast_bathymetrydata.tif are necessary to interpolate bathymetric depth along the tracks.
 	THESE FILES ARE TOO LARGE TO UPLOAD TO GITHUB: ACCESS THEM AT https://drive.google.com/file/d/1tgqo7FssszM9cs5csBMbN8YYFJPNVTBj/view?usp=sharing AND https://drive.google.com/file/d/11jZmkuOgmENO0zdYEfFjEZi9tMZvi1LQ/view?usp=sharing

	ChukchiCoastSample.mat and BeauCoastSample.mat each contain three tracks to demonstrate how the code works. For further analysis, get the full dataset from https://doi.org/10.5281/zenodo.12188016 and use ProcessingToDataset.m 


PickingRidgeLatLon.m finds the lat/lon coordinates from an identified ridge location. 

