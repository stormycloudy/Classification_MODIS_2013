;This program is to extract a 640*512 box from any Modis file of 36 bands,
;separately. Alternate is to savethe images as .eps files.
;Also, the extracted arrays are saved as band.sav file.
;This needs 36 original bands being stored in 'russia_smoke2.sav'

restore,'russia_smoke2.sav'
nx = 1354.
ny = 2030.
stddev=fltarr(36)

band=fltarr(640,512,36)
for i=0,35 do begin
 band[*,*,i]=bands[450:1089,200:711,i]
 ;device,retain=2
 ;ps_start,xsize=6.40,ysize=5.12,/inches,/encapsulated,file='hw2_6_vis.eps'
 ;window,/free,xsize=640,ysize=512
 ;tv,hist_equal(band[*,*,i])
 ;wait,2
endfor

restore,'ru2_band.sav'
vzar=vza[450:1089,200:711]
vzar=vzar*.01
f=rebin(lat,1355,2030)
latr=f[450:1089,200:711]
save,latr,vzar,file='extract_vza_lat.sav'


device,retain=2
window,/free,xsize=640,ysize=512
tv,hist_equal(band[*,*,3])
save,band,file='ru2_band.sav'
end
