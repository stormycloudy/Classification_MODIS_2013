;
;Purpose: to illustrate how to read a MODIS1B data, and
;         plot color images
;Author:  Jun Wang
;Date :   Aug. 25, 2005
;
; define input file dir and name
;
filename = 'MYD021KM.A2011200.0220.005.2011200155505.hdf'
filedir = '/nas/rhome/xuechang/Modis'
;
; Check if this file is a valid HDF file
;
if not hdf_ishdf(filename) then begin                                   
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse
;
; The SDS var name we're interested in
;
device, retain=2
SDsvar = strarr(4)
SdSVar = ['Latitude', 'Longitude','EV_250_Aggr1km_RefSB','EV_500_Aggr1km_RefSB']
;
; get the SDS data
;
; get hdf file id
FileID = Hdf_sd_start(filename, /read)
for i = 0, n_elements(SDSvar)-1 do begin
 ; based on SDSname, get the index of this SDS
 thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
 ; built connenctions / SDS is selected.
 thisSDS = hdf_sd_select(FileID, thisSDSinx)
 ; get information of this SDS
 hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                  Ndims = nd, hdf_type = SdsType
   print, 'SDAname ', thisSDSname, ' SDS Dims', nd, $
          ' SdsType = ', strtrim(SdsType,2)
 ; dimension information of SDS
   for kk = 0, nd-1 do begin
   DimID =   hdf_sd_dimgetid( thisSDS, kk)
   hdf_sd_dimget, DimID, Count = DimSize, Name = DimName
   print, 'Dim ', strtrim(kk,2), $
          ' Size = ', strtrim(DimSize,2), $
          ' Name  = ', strtrim(DimName)
   if ( i eq 2 ) then begin
     if ( kk eq 0) then np = DimSize    ; dimension size
     if ( kk eq 1) then nl = DimSize
   endif
   endfor
 ; end of entering SDS
  hdf_sd_endaccess, thisSDS
 ; get data
   HDF_SD_getdata, thisSDS, Data
 ; save data into different arrays
   if (i eq 0) then flat = data      ; lat data
   if (i eq 1) then flon = data      ; lon data
   if (i eq 2) then ref250 = data    ; Ref 250m merged to 1km
   if (i eq 3) then ref500 = data    ; Ref 500m merged to 1km
 ; print reading one SDS var data is over
  print, '========= one SDS data is over ========='
endfor
; end the access to sd
  hdf_sd_end, FileID
; start color plot, true color image combination of
; band 1 0.62-0.67 um    - red
; band 4 0.54-0.57 um    - green
; band 3 0.46-0.48 um    - blue
red = bytarr(np,nl)
green = bytarr(np,nl)
blue = bytarr(np,nl)
; manupilate data and enhance the image
red(0:np-1,0:nl-1)   = hist_equal(bytscl(ref250(0:np-1, 0:nl-1, 0)))
green(0:np-1,0:nl-1) = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 1)))
blue(0:np-1,0:nl-1) = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 0)))
; write the image into tiff
; note Aqua images need reverse, otherwise
; the north direction would pointing down.
; left and right also need to be reversed,
; in order to fit our visual experience.
   write_tiff, 'overlay-new.tif', red=reverse(reverse(red,2),1), green= reverse(reverse(green,2), 1),blue=reverse(reverse(blue,2), 1),$
           PLANARCONFIG=2
; mapping
; map limit
; region_limit = [-60, -180, 60,180]
region_limit=[min(flat),min(flon),max(flat),max(flon)] 
 win_x = 800
  win_y = 600
; pixel after reprojection, default is while pixel
  newred = bytarr(win_x, win_y)+255
  newgreen = bytarr(win_x, win_y)+255
  newblue = bytarr(win_x, win_y)+255
; MODIS only gives lat and lon not 1km resolution
; hence, interpolation is needed to have every 1km pixel
; has lat and lon
  flat =  congrid(flat, np, nl, /interp)
  flon =  congrid(flon, np, nl, /interp)
; set up window
  set_plot, 'X'
  !p.background=255L + 256L * (255+256L *255)
  window, 1, xsize=win_x, ysize=win_y
  map_set, latdel = 5, londel =10, /continent,$
        /grid, charsize=0.8, mlinethick = 2,$
    limit = region_limit, color = 0, /USA
; map pixel to the right location in the windown
; based on windown size, map cooridnate and
; the lat and lon of the pixel
  for i = 0, np-1 do begin
  for j = 0, nl-1 do begin
  result = convert_coord(flon(i,j), flat(i,j), /data, /to_device)
  newcoordx = result(0)
  newcoordy = result(1)
  newred(newcoordx, newcoordy) = red(i,j)
  newgreen(newcoordx, newcoordy)=green(i,j)
  newblue(newcoordx, newcoordy) =blue(i,j)
  endfor
  endfor
; display the reprojecte image
 tv, [[[newred]], [[newgreen]], [[newblue]]], true=3
; redraw the map with noerase opition
  map_set, latdel = 5, londel =10, /noerase, /continent,$
        /grid, charsize=0.8, mlinethick = 2,$
    limit = region_limit, color = 0, /USA

map_grid,londel=2,latdel=2,/label, /box_axes, size=2.2

map_continents,/countries, /coasts, /usa, /hires, color=0, mlinethick=1.0

cgoplot,lon,lat,xstyle=1,psym=3,xrange=[120,135],yrange=[70,80],color=cgcolor('green'),/data
cgoplot,[166,167.7],[52.1,52.1],listyle=1,color=cgcolor('green'),/data
xyouts,168,52,'CALIPSO Track',color=cgcolor('green'),/data

; write image into the file
; read current window content
;plots,102,0,psym=6,symsize=6,color=255
;Plots,Long(),Lat(),sign#,size#,color#
 image = tvrd(true=3, order=1)
; write to tiff
 write_tiff, 'projected00.tif', image,$
             PLANARCONFIG=2
end
