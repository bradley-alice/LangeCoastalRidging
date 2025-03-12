# LangeCoastalRidging

Project: Grounded Ridge Detection and Characterization along the Alaskan Arctic Coastline using ICESat-2 Surface Height Retrievals

Project Description: This repository contains code used to process ICESat-2 data to identify grounded ridges in satellite specific tracks across the Alaskan Arctic coastline. Further description of methods is contained in the publication that this code supports. 

Code Description:

ProcessingToDataset.m is the initial code which takes each individual ICESat-2 file, processed using the University of Maryland Ridge Detection Algorithm, and compiles it together into a data table. It also tests whether each track intersects the coastline and adds another column containing either ‘yes’, or ‘NA’ depending on the intersection status. This file splits the tracks into two geographic areas which we use in this analysis following the Chukchi and Beaufort Sea boundaries along the coastline. 

BulkTrackProcessing.m is the main branch of code which uses the dataset compiled in ProcessingToDataset.m and spits out a figure for each pass containing the depth estimates and bathymetry. In this code, the following functions are used: 

	distance_sparce.m calculates the distance of each measurement location to the coastline. 
	This uses the Coastline2021 shapefile (.dbf, .shp, .shx), which has a trace of the coastline of northern Alaska in lat/lon. 

	fdd_thickness.m finds the expected ice thickness for any date using two different freezing degree day models. 
	This uses heightBeau.mat and heightChuk.mat which contain calculated FDD values for several sites. 

	Bathymetry files from GEBCO are necessary to interpolate bathymetric depth along the tracks.
 	THESE FILES ARE TOO LARGE TO UPLOAD TO GITHUB: access them at https://download.gebco.net
	Use the following lat/lon boundaries: N 75.0  S 66.0 W -175.0 E -135.0
	Download both the Grid and TID Grid files in 2D netCDF format. The filenames should be:
	gebco_2024_n75.0_s66.0_w-175.0_e-135.0.nc
	gebco_2024_tid_n75.0_s66.0_w-175.0_e-135.0.nc

	ChukchiCoastSample.mat and BeauCoastSample.mat each contain three tracks to demonstrate how the code works. For further analysis, get the full dataset from https://doi.org/10.5281/zenodo.12188016 and use ProcessingToDataset.m 

	
	

