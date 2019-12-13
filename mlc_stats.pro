restore,'mmc_merge_array.sav',/verb
restore,'ru2_band.sav'
cloud_ind=where(merge eq 0, c1)
ocean_ind=where(merge eq 1, c2)
soil_ind=where(merge eq 2, c3)
veg_ind=where(merge eq 3, c4)
smoke_ind=where(merge eq 4, c5)

cghistoplot,float(merge),xtitle='Class Index',ytitle='Frequency',title='Histogram of MMC results'
xyouts,0.75,0.83,'0 - Cloud',color=cgcolor('black'),/normal
xyouts,0.75,0.8,'1 - Ocean',color=cgcolor('black'),/normal
xyouts,0.75,0.77,'2 - soil',color=cgcolor('black'),/normal
xyouts,0.75,0.74,'3 - Vegetation',color=cgcolor('black'),/normal
xyouts,0.75,0.71,'4 - Smoke',color=cgcolor('black'),/normal
image3d = TVRD(TRUE=1)
WRITE_JPEG, 'Histo_MMC.jpeg', image3d, TRUE=1, QUALITY=100


print,transpose([c1,c2,c3,c4,c5])


b=[ [[band[*,*,0]]],$
  [[band[*,*,1]]],$
  [[band[*,*,2]]],$
  [[band[*,*,4]]],$
  [[band[*,*,19]]],$
  [[band[*,*,30]]],$
  [[band[*,*,31]]] ]

num=640*512L
data=reform(b,num,(size(b))[3])

mlc_mean=fltarr(7,5)
mlc_std=mlc_mean

for i =0,6 do begin
  mlc_mean[i,0]=mean((data[*,i])[cloud_ind])
  mlc_std[i,0]=stddev((data[*,i])[cloud_ind])
  
  mlc_mean[i,1]=mean((data[*,i])[ocean_ind])
  mlc_std[i,1]=stddev((data[*,i])[ocean_ind])
  
  mlc_mean[i,2]=mean((data[*,i])[soil_ind])
  mlc_std[i,2]=stddev((data[*,i])[soil_ind])  
  
  mlc_mean[i,3]=mean((data[*,i])[veg_ind])
  mlc_std[i,3]=stddev((data[*,i])[veg_ind])  
  
  mlc_mean[i,4]=mean((data[*,i])[smoke_ind])
   mlc_std[i,4]=stddev((data[*,i])[smoke_ind])
 endfor
  
print,mlc_mean
print,'----------'
print,mlc_std



end  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  