#!/bin/bash

# debated about using a 2-dimensional array but thought this would be easier to separate and change as necessary
years=(2005 2009 2010 2012 2014)
#naipfiles=(indexes/FSA_DOQQ/*.shp)
naipfiles=(naip_ca_2005_1m_nc  naip_ca_2009_1m_m4b naip_ca_2010_1m_m4b  naip_ca_2012_1m_m4b ca_naip14qq)

cd /mnt/nas

for (( i = 0 ; i < ${#naipfiles[@]} ; i++ )) do
	# No need to repeat if the file already exists
	if [ ! -e indexes/naip_${years[$i]}.csv -a -e "indexes/FSA_DOQQ/${naipfiles[$i]}.shp" ]; then
		ogr2ogr -f CSV indexes/naip_${years[$i]}.csv indexes/FSA_DOQQ/${naipfiles[$i]}.shp -sql "SELECT filename FROM ${naipfiles[$i]} ORDER BY filename DESC" 
		# get rid of the verification date
		sed -i.bak 's/_.\{8\}.tif/.tif/' indexes/naip_${years[$i]}.csv
	fi
	if [ -d "NAIP_${years[$i]}_DOQQ" ]; then
		echo "filename," >  indexes/ucd_files_${years[$i]}.csv
		find "NAIP_${years[$i]}_DOQQ" \(  -iname 'n*.tif' -o -iname 'm*.tif' \) -type f  2>/dev/null -printf "%f\n" | sort -r >> indexes/ucd_files_${years[$i]}.csv
		if [ ${years[$i]} -eq 2005 ]; then
			# make near infrared filename list
			find "NAIP_${years[$i]}_DOQQ" \(  -iname 'c*.tif' \) -type f  2>/dev/null -printf "%f\n" | sort -r >> indexes/ucd_cir_${years[$i]}.csv
		fi
		#list missing files
		if [ -e "indexes/naip_${years[$i]}.csv"  -a  -e "indexes/ucd_files_${years[$i]}.csv"  ]; then
			comm -23  indexes/naip_${years[$i]}.csv indexes/ucd_files_${years[$i]}.csv >> indexes/ucd_missing_${years[$i]}.txt
			# Might as well examine these
			comm -13  indexes/naip_${years[$i]}.csv indexes/ucd_files_${years[$i]}.csv >> indexes/naip_missing_${years[$i]}.txt
			
			# Start building list of filenames to join to indexes
			#while read -r line; do echo "${line}, ${line:2:7}, ${line:10:2}, ${line:2:10}, ${line:18:8}"  >> indexes/ucd_index_${years[$i]}.csv; done < indexes/ucd_files_${years[$i]}.csv
			awk 'BEGIN{FS="_"; OFS=", ";} NR>1 {print $0, $2FS$3, $2, substr($2,6,2), $3, substr($6,1,8)}' indexes/ucd_files_${years[$i]}.csv > indexes/ucd_index_${years[$i]}.csv;
		fi
	fi
done

# Get quarterquadrants from all files and remove duplicates based on the 4rth column (usgis quad identifier and quarter quadrant)
sort -t, -uk2 indexes/ucd_index*.csv |  awk 'BEGIN{FS=","; OFS=",";}{print $2, $3, $4, $5, $6}' > indexes/qtrquad_index

# build indexes
# first write a csv creating the coordinates of the bounding polygons and some attribures from the filename
python indexes/buildIndex2.py
# build a shapefile 
ogr2ogr -f "ESRI Shapefile" -overwrite indexes/NAIP_index.shp indexes/NAIP_index.vrt


# finish - ogr2ogr -sql "select NAIP_index.*, ucd_index_${years[$i]}.* from NAIP_Index.shp left join 'ucd_index_${years[$i]}.csv'.joincsv on NAIP_index.quad_qdrnt = ucd_index_${years[$i]}.quad_qdrnt" NAIP_index_1.shp NAIP_index.shp
