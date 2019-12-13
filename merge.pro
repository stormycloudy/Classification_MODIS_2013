
restore,'ru2_cluster.sav',/verb
;make background
device,decomposed=0,retain=2
loadct,13,bottom=0,ncolors=255
!p.background=255
!p.color=0

;colortable
; 	   white	    tawry	olive	navy	g-blue	cyan	light	grey	grey	red
;red  =[255,		183,	180,	052,	102,	068,	200,	137,	213,	255,	255]
;green=[255,		150,	196,	143,	153,	249,	255,	137,	253,	000,	219]
;blue =[255,		042,	042,	255,	158,	255,	255,	137,	197,	000,	012]

;colortable
;		white	light	cyan1	cyan2	green	olive	cyan3	navy	g-blue	cyan4	grey
red  =[255,		200,	068,	149,	057,	180,	145,	007,	102,	187,	177]
green=[255,		255,	249,	221,	193,	196,	255,	080,	153,	238,	177]
blue =[255,		255,	255,	255,	093,	062,	254,	170,	158,	255,	177]

color_ind=[0,1,2,3,4,5,6,7,8,9,10]

;colorbar
window,/free, xsize=640, ysize=580
tvlct,red,green,blue
tv,cluster,0,68


ClassArr=['Class1','Class2','Class3','Class4','Class5','Class6','Class7','Class8','Class9','Class10','Class11']

shay_colorbar,ClassArr,color_ind,xstart=.1,xend=.9,loc = [0.1, 0.044, 0.9, 0.096]

image3d = TVRD(TRUE=1)
WRITE_JPEG, 'MMC.jpeg', image3d, TRUE=1, QUALITY=100


; 	white	    navy	olive	green	g-blue
r1=[255,		007,	180,	057,	102];
g1=[255,		080,	196,	193,	153];
b1=[255,		170,	062,	093,	158];
color_ind1=[0,1,2,3,4]

merge=bytarr(640,512)
num=640*512L
for i=0,num-1 do begin
 if cluster[i] eq 0 or cluster[i] eq 1 or cluster[i] eq 2 or cluster[i] eq 3 or cluster[i] eq 4 $
 or cluster[i] eq 6 or cluster[i] eq 10 then merge[i]=0
 if cluster[i] eq 4 then merge[i] = 3
 if cluster[i] eq 5 then merge[i] = 2
 if cluster[i] eq 7 then merge[i] = 1
 if cluster[i] eq 8 then merge[i] = 4
endfor

window,/free, xsize=640, ysize=580
tvlct,r1,g1,b1
tv,merge,0,68
ClassArr1=['Cloud','Ocean','Soil','Vegetation','Smoke']

shay_colorbar,ClassArr1,color_ind1

image3d = TVRD(TRUE=1)
WRITE_JPEG, 'MMC_merge.jpeg', image3d, TRUE=1, QUALITY=100

end
