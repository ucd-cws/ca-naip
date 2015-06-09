#! /bin/bash

# debated about using a 2-dimensional array but thought this would be easier to separate and change as necessary
years=(2005 2009 2010 2012 2014)

cd /mnt/nas
j=0
for yr in "${years[@]}"; do
	if [ -d "NAIP_$yr_County_Mosaics" ]; then
		find "NAIP_$yr_County_Mosaics" \(  -iname '*.sid' -o -iname '*.jp2' \) -type f  2>/dev/null -printf "%f\n" |  awk 'BEGIN{FS="_"; OFS=",";} {print $0, substr($5,3,5)}' >> indexes/ucd_ccm_$yr.csv
	fi
	if [ -e "indexes/ucd_ccm_$yr.csv"  ]; then
		ogr2ogr -overwrite -sql "select COUNTY, SURVEY_UNI, COUNTY_NAM, FIPS, STATE, field_1 as fname_$yr from CA_County_Web_$j left join 'indexes/ucd_ccm_$yr.csv'.ucd_ccm_$yr on CA_County_Web_$j.COUNTY = ucd_ccm_$yr.field_2" indexes/CA_County_Web_${j+1}.shp indexes/CA_County_Web_$j.shp
		# get rid of all intermediate indexes but save the _0 one, in case this needs to be rebuilt!
		if [ j > 0 ]; then
			rm indexes/CA_County_Web_${j}.*
		fi
		((j+=1))
	fi
done
# rename to CA_County_Web
ogr2ogr -overwrite indexes/CA_County_Web.shp indexes/CA_County_Web_$j.shp
rm indexes/CA_County_Web_$j.*
