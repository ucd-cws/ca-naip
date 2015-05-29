latlongMult = {"se":[0,0],"sw":[0,1],"ne":[1,0],"nw":[1,1]}
with open(r"fileList.csv", 'r') as infile, open(r"NAIP_index.csv", 'w') as outfile:
    outfile.write("usda_quad,degree_cell,color,date,filename,geo\n") 
    for line in infile:
        parts = line.split('_')
        qtrquad = parts[2].lower()
        tifdate = parts[5][0:8]
        try:
            ll_mult=latlongMult[qtrquad]           
        except KeyError:
            with open(r"NAIP_errror.csv", 'a') as errorfile:
                errorfile.write('Error in qtrquad conversion' + str(line))

        try:
            deglat = int(parts[1][0:2])
            deglong =int(parts[1][2:5])
            quadnum = int(parts[1][-2:])
            outfile.write(str(parts[1]) + ', ' + str(parts[1][0:5])  + ', ' + str(parts[0]) + ', ' + str(tifdate) + ', ' + str(line.strip('\n')) + ', ' +
                '"Polygon ((' + str((deglong + (((64.0-quadnum)%8)*.125) + (ll_mult[1]*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + (ll_mult[0]*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + ((ll_mult[1]+1)*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + (ll_mult[0]*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + ((ll_mult[1]+1)*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + ((ll_mult[0]+1)*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + (ll_mult[1]*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + ((ll_mult[0]+1)*.0625)) + ', ' +
                str((deglong + (((64.0-quadnum)%8)*.125) + (ll_mult[1]*.0625))*-1) + ' ' + str(deglat + (((64.0-quadnum)//8)*.125) + (ll_mult[0]*.0625)) + '))"' +'\n')
          
        except ValueError:
            with open(r"NAIPerrror.csv", 'a') as errorfile:
                errorfile.write('Error in float conversion' + str(line))
       

