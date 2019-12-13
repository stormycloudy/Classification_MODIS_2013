; Program that uses Minimum Distance Classifier to classify 5 classes of 3 bands (band2,5,32)
; And disply a colored thematic map
; For the image: Large wildfires began to burn in parts of Quebec, Canada during the last few days of May 2010. 

restore,'ru2_band.sav'
b2=band[*,*,1]
b3=band[*,*,2]
b32=band[*,*,31]
n=640*512L

cloud_band2=0.411
ocean_band2= 0.01569
veg_band2=0.252
soil_band2=0.229
smoke_band2=0.060

cloud_band3=0.423
ocean_band3=0.1043
veg_band3=0.108
soil_band3= 0.137
smoke_band3=0.159

cloud_band32=274.342
ocean_band32=281.149
veg_band32=292.568
soil_band32=295.627
smoke_band32=280.232

img=fltarr(640,512)

;MDC for each class
for i=0L,n-1 do begin
 d1=sqrt((b2[i]-cloud_band2)^2+(b3[i]-cloud_band3)^2+(b32[i]-cloud_band32)^2)
 d2=sqrt((b2[i]-ocean_band2)^2+(b3[i]-ocean_band3)^2+(b32[i]-ocean_band32)^2)
 d3=sqrt((b2[i]-soil_band2 )^2+(b3[i]-soil_band3 )^2+(b32[i]-soil_band32 )^2)
 d4=sqrt((b2[i]-veg_band2  )^2+(b3[i]-veg_band3  )^2+(b32[i]-veg_band32  )^2)
 d5=sqrt((b2[i]-smoke_band2)^2+(b3[i]-smoke_band3)^2+(b32[i]-smoke_band32)^2)
 ;d6=sqrt((b2[i]-wc_band2   )^2+(b3[i]-wc_band3   )^2+(b32[i]-wc_band32   )^2)
 distance=[d1,d2,d3,d4,d5]
 ind=where(distance eq min(distance))
 img[i]=ind
endfor

;make background
device,decomposed=0,retain=2
loadct,13,bottom=0,ncolors=255
!p.background=255
!p.color=0

;colortable
; white	    navy	brown	green	orange	pink	blue
r=[255,		028,	147,	039,	255,	255];,	133]
g=[255,		083,	075,	146,	165,	191];,	255]
b=[255,		150,	034,	059,	029,	249];,	249]
color_ind=[0,1,2,3,4,5]

;colorbar
window,/free, xsize=640, ysize=580
tvlct,r,g,b
tv,img,0,68
loc = [0.15, 0.044, 0.85, 0.096]

ClassArr=['Cloud','Ocean','Soil','Vegetation','Smoke'];,'Water Cloud']
nc=n_elements(ClassArr)
xstart=.15
ystart=.07
xend=.85
xse=[xstart,xend]
yse=[ystart,ystart]
xstp=(xse[1]-xse[0])/(nc*1.)
for i=0, nc-1 do begin
 x=[xse[0]+xstp*i,xse[0]+xstp*(i+1)]
 y=[yse[0],yse[1]]
 plots,x,y,thick=30,color=color_ind[i],/normal
 xyouts,xse[0]+xstp*i,yse[0]-.04,ClassArr[i],color=7;charsize=1.,charthick=2.
endfor
plots, [loc[0], loc[0], loc[2], loc[2], loc[0]], $
       [loc[1], loc[3], loc[3], loc[1], loc[1]], color=7,/Normal
image3d = TVRD(TRUE=1)
WRITE_JPEG, 'MDC.jpeg', image3d, TRUE=1, QUALITY=100
end
