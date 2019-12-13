;Cluster migrating means method
T = SYSTIME(1)  

restore,'ru2_band.sav'

n=640*512L
;b2 =bytscl(band[*,*, 1],max=1.)*1.0
;b32=bytscl(band[*,*,31])*1.0
;b2_1d =reform(b2,1,n)
;b32_1d=reform(b32,1,n)
;b=[b2_1d,b32_1d] 

bd=[	[[bytscl(band[*,*,0],max=1.)*1.0]],[[bytscl(band[*,*,1],max=1.)]],$
		[[bytscl(band[*,*,2],max=1.)]],[[bytscl(band[*,*,4])]],$
		[[bytscl(band[*,*,19])]],$
		[[bytscl(band[*,*,30])]],[[bytscl(band[*,*,31])]]  ]

num_band=(size(bd))[3]
b=fltarr(num_band,n)
for i = 0,num_band-1 do begin
 b[i,*]=reform(bd[*,*,i],1,n)
endfor


;9 arbitrary cluster centers
;8 bands
u=[ [210,210,200,210,210,200,205],$
	[190,195,195,190,195,195,185],$
	[180,180,175,180,180,170,180],$
	[165,160,165,165,165,160,165],$
	[140,140,140,145,140,140,145],$
	[125,115,125,125,125,130,125],$
	[100,107,100,105,100,100,105],$
	[087,085,080,080,089,080,080],$	
	[065,069,065,065,075,065,071],$
	[052,050,050,055,050,050,050],$
	[027,035,025,035,035,032,035]	  ]


;Set initial parameters for repeat cycle
SSE=0.  
new_u_valid=u
new_u=make_array((size(u))[1],(size(u))[2],/float,value=300.)
k=0

repeat begin
u=new_u_valid
cols=(size(u))[1]
rows=(size(u))[2]
cluster = intarr(640,512);Classifying results set to 0
last_sse=sse
e=fltarr(rows)
se=dblarr(rows)

for i = 0L,n-1 do begin
 for j =0,rows-1 do begin
   e[j]=sqrt((b[0,i]-u[0,j])^2+(b[1,i]-u[1,j])^2+(b[2,i]-u[2,j])^2$
	+(b[3,i]-u[3,j])^2+(b[4,i]-u[4,j])^2+(b[5,i]-u[5,j])^2$
	+(b[6,i]-u[6,j])^2);Eucliean distancce
 endfor
  min_ind=where(e eq min(e))
  cluster[i]=min_ind
endfor

for j = 0,rows-1 do begin
 cluster_sse,cluster,b,u,j,SSE=sse0,new_u=new_u0
 se[j]=sse0
; SSE=SSE+sse0
 new_u[*,j]=new_u0
endfor

sse=total(se)

valid_ind=where(new_u[0,*] lt 300)
new_u_valid=new_u[*,valid_ind]

ap=array_equal(u,new_u_valid)

print,'new u'
print,new_u[*,valid_ind]
print,'SSE=',SSE

diff=last_sse - SSE

k++
endrep until ((diff lt 2E4 and diff gt 0) or (SSE lt 5E4) or ap eq 1)

;save,cluster,file='ru2_cluster.sav'

print,'Cycles:',k
PRINT, SYSTIME(1) - T, 'Seconds'

;------------------------display & colorbar------------------

;restore,'ru2_cluster.sav',/verb
;make background
device,decomposed=0,retain=2
loadct,13,bottom=0,ncolors=255
!p.background=255
!p.color=0

;colortable
; 	   white	    tawry	olive	navy	g-blue	cyan	light	green	grey	red
;red  =[255,		183,	180,	052,	102,	068,	200,	213,	137,	255,	255]
;green=[255,		150,	196,	143,	153,	249,	255,	253,	137,	000,	219]
;blue =[255,		042,	042,	255,	158,	255,	255,	197,	137,	000,	012]

;colortable
;		white	light	cyan1	cyan2	lightgrey	green	olive	grey	navy	cyan3	
red  =[255,		200,	068,	149,	197,		000,	180,	137,	008,	185,	084]
green=[255,		255,	249,	221,	222,		170,	196,	137,	023,	204,	134]
blue =[255,		255,	255,	255,	233,		015,	062,	137,	160,	233,	173]

color_ind=[0,1,2,3,4,5,6,7,8,9,10]

;colorbar
window,/free, xsize=640, ysize=580
tvlct,red,green,blue
tv,cluster,0,68


ClassArr=['Class1','Class2','Class3','Class4','Class5','Class6','Class7','Class8','Class9','Class10','Class11']

shay_colorbar,ClassArr,color_ind,xstart=.1,xend=.9,loc = [0.1, 0.044, 0.9, 0.096]

image3d = TVRD(TRUE=1)
WRITE_JPEG, 'MMC2.jpeg', image3d, TRUE=1, QUALITY=100


; 	white	    navy	olive	green	g-blue
r1=[255,		007,	180,	057,	102];
g1=[255,		080,	196,	193,	153];
b1=[255,		170,	062,	093,	158];
color_ind1=[0,1,2,3,4]



end

