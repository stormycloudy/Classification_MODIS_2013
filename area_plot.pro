 window,/free,xsize=700,ysize=700
 
 cgplot,mmc[0]/1000.,mlc[0]/1000.,PSYM=16,SYMCOLOR=CGCOLOR('sky blue'),SYMSIZE =4.0,yrange=[0,120],xrange=[0,120],xtitle='Area (1000 km^2) Unsupervised Classification (MMC)',$
  ytitle='Area (1000 km^2) Supervised Classification (MLC)',background=cgcolor('white'), title='Area Covered by Each Class'
 cgoplot,mmc[1]/1000.,mlc[1]/1000.,PSYM=16,SYMCOLOR=CGCOLOR('navy'),SYMSIZE =4.0,yrange=[0,120],xrange=[0,120]
 cgoplot,mmc[2]/1000.,mlc[2]/1000.,PSYM=16,SYMCOLOR=CGCOLOR('goldenrod'),SYMSIZE =4.0,yrange=[0,120],xrange=[0,120]
 cgoplot,mmc[3]/1000.,mlc[3]/1000.,PSYM=16,SYMCOLOR=CGCOLOR('forest green'),SYMSIZE =4.0,yrange=[0,120],xrange=[0,120]
 cgoplot,mmc[4]/1000.,mlc[4]/1000.,PSYM=16,SYMCOLOR=CGCOLOR('grey'),SYMSIZE =4.0,yrange=[0,120],xrange=[0,120]
 cgoplot,[0,120],[0,120],psym=-3,color=cgcolor('black'),linestyle=2,thick=3,/data
 
XYOUTS, .8, .58, 'Cloud', COLOR=cgCOLOR('sky blue'), /NORMAL
XYOUTS, .8, .55, 'Ocean', COLOR=cgCOLOR('navy'), /NORMAL
XYOUTS, .8, .49, 'Soil', COLOR=cgCOLOR('goldenrod'), /NORMAL
XYOUTS, .8, .52, 'Vegetation', COLOR=cgCOLOR('forest green'), /NORMAL
XYOUTS, .8, .46, 'Smoke', COLOR=cgCOLOR('grey'), /NORMAL


image3d = TVRD(TRUE=1)
WRITE_JPEG, 'Area_plot.jpeg', image3d, TRUE=1, QUALITY=100



end