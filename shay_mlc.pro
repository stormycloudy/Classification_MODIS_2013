; docformat = 'rst'
;+
;
; Maximum likelihood classifyer function
;
; :Private:
;
; :Categories:
; Remote Sensing/ATS670 Homework 4
;
; :Examples:
; for i =0L,num-1 do begin
;  img[i]=shay_mlc(data[i,*],sample=sample)
; endfor 
;
;
; :Author:
; Xuechang "Shay" Liu, UAH, xuechang at nsstc.uah.edu 
;
; :History:
; First written: March 20, 2013
;
;−
;
Pro shay_mlc_param,sample,U=u,Determinant=determinant,Inver_epsilon=inver_epsilon
;+
; A helper procedure that computes mean, standard deviation, determinant and $
; inverse covariance matrix.
;
;
; :Params:
; sample : in, required, type=numerical array
; A 3-dimensional training samples' array of bands*pixels*classes
;
; :Keywords:
; U : out, optional, type=numerical array
; Determinant : out, optional, type=numerical array
; Inver_epsilon : , optional, type=numerical array
;
;
;−

n_class=(size(sample))[3]
num_band=(size(sample))[1]
u=dblarr(n_class,num_band)
std=dblarr(n_class,num_band)
epsilon=dblarr(num_band,num_band,n_class)
inver_epsilon=dblarr(num_band,num_band,n_class)
determinant=dblarr(n_class)

;compute each class' mean by band
;column:class number,row:band number
for k = 0,n_class-1 do begin
 for i =0,num_band-1 do begin
  u[k,i]=mean(sample[i,*,k])
  std[k,i]=stddev(sample[i,*])
 endfor
endfor

;compute the covariance matrix of each class
for k=0,n_class-1 do begin
  epsilon[*,*,k]=correlate(sample[*,*,k],/covariance)
  determinant[k]=determ(epsilon[*,*,k])
  inver_epsilon[*,*,k]=invert(epsilon[*,*,k])
endfor

end

Function shay_mlc,vector,Sample=sample
;+
; Main function that computes and compares and classify a single MODIS $
; image pixel of 7 bands.
;
; :Returns:
; A integer that describes the class of the this pixel.
;
; :Params:
; vector : in, required, type=numerical array
; a 1-column by multi-row array of the pixel value of all selected bands
;
; :Keywords:
; Sample : in, optional, type=numerical array
; Training samples of all classes
;
; :Uses:
; shay_mlc_param
;
;−

compile_opt idl2

;error catcher:
CATCH, theError
IF theError NE 0 THEN BEGIN
CATCH, /cancel
HELP, /LAST_MESSAGE, OUTPUT=errMsg
FOR i=0, N_ELEMENTS(errMsg)-1 DO print, errMsg[i]
RETURN,-1
ENDIF

shay_mlc_param,sample,U=u,Determinant=determinant,Inver_epsilon=inver_epsilon
n_class=(size(u))[1]
num_band=(size(u))[2]
deviate=dblarr(n_class,num_band) ;x-u
deviate_t=transpose(deviate)
g=dblarr(n_class)

;For a single pixel 7-band vector
for k=0,n_class-1 do begin
	for j =0,num_band-1 do begin
 	 deviate[k,j]=vector[0,j]-u[k,j]
	endfor
 deviate_t[*,k]=transpose(deviate[k,*])
 g[k]=-alog(abs(determinant[k]))-deviate_t[*,k]##inver_epsilon[*,*,k]##deviate[k,*]
endfor
ind=where(g eq max(g))
return,ind
end

;main
T = SYSTIME(1)  

restore,'ru2_band.sav'
restore,'cloud_training_samples.sav' 
restore,'ocean_training_samples.sav' 
restore,'soil_training_samples.sav' 
restore,'veg_training_samples.sav' 
restore,'smoke_training_samples.sav' 

num=640*512L

sample=[[[cloud]],[[ocean]],[[soil]],[[veg]],[[smoke]]]
;SAMPLE          FLOAT     = Array[7, 10, 5]



b=[ [[band[*,*,0]]],$
	[[band[*,*,1]]],$
	[[band[*,*,2]]],$
	[[band[*,*,4]]],$
	[[band[*,*,19]]],$
	[[band[*,*,30]]],$
	[[band[*,*,31]]] ]


data=reform(b,num,(size(b))[3])
img=dblarr(640,512)
;DATA            FLOAT     = Array[327680, 10]


for i =0L,num-1 do begin
 img[i]=shay_mlc(data[i,*],sample=sample)
endfor
save,img,file='mlc.sav'

PRINT, SYSTIME(1) - T, 'Seconds'

;make background
device,decomposed=0,retain=2
loadct,13,bottom=0,ncolors=255
!p.background=255
!p.color=0

;colortable
; white	    navy	olive	green	g-blue
r=[255,		007,	180,	057,	102];
g=[255,		080,	196,	193,	153];
b=[255,		170,	062,	093,	158];
color_ind=[0,1,2,3,4]

;colorbar
window,/free, xsize=640, ysize=580
tvlct,r,g,b
tv,img,0,68

ClassArr=['Cloud','Ocean','Soil','Vegetation','Smoke']
;The order should be the consistent with array sample.

shay_colorbar,ClassArr,color_ind

image3d = TVRD(TRUE=1)
WRITE_JPEG, 'MLC.jpeg', image3d, TRUE=1, QUALITY=100

end

