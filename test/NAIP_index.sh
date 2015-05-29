#! /bin/bash

python buildIndex2.py
ogr2ogr -f "ESRI Shapefile" NAIP_index_test.shp NAIP_index.vrt
