restore,'ru2_band.sav'

b=band
b1=b[*,*,0];Red
b4=b[*,*,3];Green
b3=b[*,*,2];Blue
num=20	
device,retain=2
window,xsize=640,ysize=512,0

CH1=HIST_EQUAL(b1)
CH2=HIST_EQUAL(b4)
CH3=HIST_EQUAL(b3)
overlay=COLOR_QUAN(ch1,ch2,ch3,Red,Green,Blue,COLORS=256)
tvlct,red,green,blue
tvimage,overlay


; pick region of interest using box_cursor
xs = 640 ; xsize for window
ys = 512 ; ysize for window

pos=fltarr(2,20)

xw=1.0 ;the size of a single sample
yw=1.0

;Pick region using box cursor
i=0
repeat begin
aa = wmenu(['Select: ','Get region','Exit'],title=0,init=1)
if aa eq 2 || i ge num then begin
 wdelete,0
endif

if aa eq 1 && i lt num then begin 
wset,0
box_cursor,x0,y0,xw,yw,FIXED_SIZE=50.0
   
;center of the box
xcen = (x0+xw/2)-1
ycen = (y0+yw/2)-1
newxw = xw/2 - 1
newyw = yw/2 - 1
print,format='(a4,i2,a15,a16,a36)','Pick',i+1,'Start Position','Size','Center Postion'
print,x0,y0,xw,yw,xcen,ycen

pos[*,i]=[xcen,ycen]
endif
i += 1
endrep until(aa eq 2 || i ge num)  

print,pos

end

;img[pos[0,*],pos[1,*]]




