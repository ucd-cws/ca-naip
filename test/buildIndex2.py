import math
from datetime import datetime

latlongMult = {"se":[0,0],"sw":[0,1],"ne":[1,0],"nw":[1,1]}

def getStName(degrees,quadnum):
	chrpart = chr(104-int(math.floor((quadnum-1)//8)));
	remCode = str(8-((quadnum - 1) % 8));
	outCode = degrees + chrpart + remCode;
	return outCode;
	
with open(r"indexes/qtrquad_index", 'r') as infile, open(r"indexes/NAIP_index.csv", 'w') as outfile:
    outfile.write("cell, quad_cell, quad_qdrnt, usgs_cell, degrees, qtrquad, geo\n") 
    for line in infile:
        parts = line.split('_')
        qtrquad = parts[1].strip('\n').lower()
        try:
            ll_mult=latlongMult[qtrquad]
            deglat = int(parts[0][0:2])
            deglong = int(parts[0][2:5])
            degrees = str(parts[0][0:5])
            quadnum = int(parts[0][5:7])
            quad_cell = getStName(degrees,quadnum)
            outfile.write(quad_cell + qtrquad + ',' + quad_cell + ',' + str(line.strip('\n')) + ',' + str(parts[0])  + ',' + degrees + ',' + str(qtrquad) + ',' + 
                '"Polygon ((' + str((deglong + (((64.0-quadnum)%8)*.125) + (ll_mult[1]*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + (ll_mult[0]*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + ((ll_mult[1]+1)*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + (ll_mult[0]*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + ((ll_mult[1]+1)*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + ((ll_mult[0]+1)*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + (ll_mult[1]*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + ((ll_mult[0]+1)*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + (ll_mult[1]*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + (ll_mult[0]*.0625)) + '))"' +'\n')
        except KeyError:
            with open(r"indexes/qtrquad_index_error", 'a') as errorfile:
                errorfile.write('Error in qtrquad conversion' + str(line))          
        except ValueError:
            with open(r"indexes/qtrquad_index_error", 'a') as errorfile:
                errorfile.write('Error in float conversion' + str(line))
       

