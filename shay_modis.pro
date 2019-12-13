; docformat = 'rst'
;+
;
; The procedure to read in any MODIS data and store 36 bands in .sav file
;
; :Private:
;
; :Categories:
; Remote Sensing/ATS670
;
; :Examples:
; shay_modis, 'MYD021KM.A2010109.1305.005.2010111050209.hdf'
;
; :Uses:
; modis_l1b_read
;
; :Author:
; Xuechang "Shay" Liu, UAH, xuechang at nsstc.uah.edu 
;
; :History:
; First written: Feb, 2013
;
;-
;
Pro shay_modis, filename,Save=save, Display=display
;+
; The main procedure to read in any MODIS data and store 36 bands in .sav file
; Option to display 36 bands on screen every 1 seoncd
;
;
; :Params:
; filename : in, required, type=string
;
; :Keywords:
; Save : in, optional, type=boolean
; Option to save 36 bands as a .sav file
;  Display: in, optional, type=boolean
; Option to display 36 bands on screen every 1 seoncd
;
; :Uses:
; modis_l1b_read
;
;-

compile_opt idl2

;error catcher:
CATCH, theError
IF theError NE 0 THEN BEGIN
CATCH, /cancel
HELP, /LAST_MESSAGE, OUTPUT=errMsg
FOR i=0, N_ELEMENTS(errMsg)-1 DO print, errMsg[i]
RETURN
ENDIF

;Check parameter
IF ~filename THEN MESSAGE, 'Please pass a variable'

;Check keyword
do_save = KEYWORD_SET(save)
do_display=KEYWORD_SET(display)

;filename='MYD021KM.A2010109.1305.005.2010111050209.hdf'

nx = 1354
ny = 2030
tn = 36
bands=fltarr(nx,ny,tn)
stddev=fltarr(36)
;---------------------------Read reflectance from bands 1-19,26-------------
 for i = 1,19 do begin 
   modis_l1b_read,filename,i,band,/reflectance
   j=i-1
   bands[*,*,j]=band[*,*]
 endfor
 
for i = 26,26 do begin 
   modis_l1b_read,filename,i,band,/reflectance
   j=i-1
   bands[*,*,j]=band
 endfor
;---------------------------Read temperature from bands 20-25, 27-36--------
 for i = 20,25 do begin 
   modis_l1b_read,filename,i,band,/temperature
   j=i-1
   bands[*,*,j]=band
 endfor
 for i = 27,36 do begin 
   modis_l1b_read,filename,i,band,/temperature
   j=i-1
   bands[*,*,j]=band
 endfor

;Horizontal flip bands' data
for i=0,35 do begin
 bands[*,*,i]=reverse(bands[*,*,i])
endfor

modis_l1b_read,filename,1,band,/reflectance,VIEWZENITH=vza,LATITUDE=LAT



;display each band on screen every 1 second.
if do_display then begin
 for i=0,35 do begin
  window,XSIZE=nx/2,YSIZE=ny/2
  tvscl,bands[*,*,i]
  wait,1
 endfor
endif

;vis=bands[*,*,3]

if do_save then begin
 save,bands,file='russia_smoke2.sav'; Save all the bands 
 save,vza,lat,file='vza_lat.sav'; Save all the bands 
endif
end
;main
shay_modis,'MYD021KM.A2011200.0220.005.2011200155505.hdf',/save
end
