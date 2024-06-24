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

	bathymetry_latlon_grid.mat and GEBCO_AlaskaCoast_bathymetrydata.tif are necessary to interpolate bathymetric depth along the tracks.

	ChukchiCoastSample.mat and BeauCoastSample.mat each contain three tracks to demonstrate how the code works. For further analysis, get the full dataset from https://doi.org/10.5281/zenodo.12188016 and use ProcessingToDataset.m 


PickingRidgeLatLon.m finds the lat/lon coordinates from an identified ridge location. 

Contour-20.shp is the 20m bathymetric contour from GEBCO;
SLIE2022Projected.shp is the landfast ice edge for 2022 from Cooley et al., 2024;
