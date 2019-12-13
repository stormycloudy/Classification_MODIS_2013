;Statistics

restore,'ru2_band.sav'
b=bytscl(band)
mean_all_px=fltarr(36)
for i=0,35 do begin
 mean_all_px[i]=mean(b[*,*,i])
endfor

end
