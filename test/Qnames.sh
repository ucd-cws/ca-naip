#!/bin/bash
naipfiles=(naip_ca_2005_1m_nc  naip_ca_2009_1m_m4b naip_ca_2010_1m_m4b  naip_ca_2012_1m_m4b ca_naip14qq)
years=(2005 2009 2010 2012 2014)

cd /mnt/nas
# do 2014 first
for (( i=${#naipfiles[@]}-1; i>=0; i-- )) do
	# No need to repeat if the file already exists
	if [ ! -e indexes/naip_qqname_${years[$i]}.csv -a -e "indexes/FSA_DOQQ/${naipfiles[$i]}.shp" ]; then
		ogr2ogr -f CSV indexes/naip_qqname_${years[$i]}.csv indexes/FSA_DOQQ/${naipfiles[$i]}.shp -sql "SELECT USGSID,Qdrnt,UTM,QQNAME FROM ${naipfiles[$i]} ORDER BY USGSID" 
	fi
done

# Get quarterquadrants from all files and remove duplicates based on the 4rth column (usgis quad identifier and quarter quadrant)
sort -t, -uk1,2 indexes/naip_qqname_*.csv |  awk 'BEGIN{FS=","; OFS=",";} {print $1"_"$2,$3,$4}' > indexes/qqname.csv

ogr2ogr -overwrite -sql "select * from NAIP_Index left join 'indexes/qqname.csv'.qqname b on NAIP_Index.quad_qdrnt = b.field_1" indexes/NAIP_index_qqname.shp indexes/NAIP_index.shp
ogrinfo indexes/NAIP_index_qqname.shp -sql "ALTER TABLE NAIP_index_qqname RENAME COLUMN field_2 TO utm"
ogrinfo indexes/NAIP_index_qqname.shp -sql "ALTER TABLE NAIP_index_qqname RENAME COLUMN field_3 TO qqname"
ogrinfo indexes/NAIP_index_qqname.shp -sql "ALTER TABLE NAIP_index_qqname DROP COLUMN field_1"
