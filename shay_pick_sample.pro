; docformat = 'rst'
;+
;
; This program will draw a visible channel image on screen
; and let user pick 10 samples interactively.
;
; :Private:
;
; :Categories:
; Remote Sensing Research/ATS670 Homework
;
; :Examples:
; shay_pick_sample,'band.sav',U=u,Std=std,Val_std=val_std,Val_u=val_u,Sample=sample
;
;
; :Author:
; Xuechang "Shay" Liu, UAH, xuechang at nsstc.uah.edu 
;
; :History:
; Modification History::
; First written: March 4,2013
;
;−
;
Pro shay_pick_sample,filename,U=u,Std=std,Val_std=val_std,Val_u=val_u,Sample=sample
;+
; This procedure will display band 4 of Modis data on screen and let user pick 5 samples.
; Optional is to output the mean values and standard deviation of each class.
;
;
; :Params:
; filename: in, required, type=string
; This should be the filename of a .sav file, which contains 36 bands of 640*512 Modis data.
;
; :Keywords:
; U : in, optional, type=boolean
; Std : in, optional, type=boolean
; Val_u : out, optional, type=numerical array
; 	A float array that stores mean values of 10 samples of 10 bands
; Val_std : out, optional, type=numerical array
; 	A float array that stores std.dev values of 10 samples of 10 bands
; Sample : out, optional, type=numerical array
; 	The array to store all picks' mean value by band
;
;−
compile_opt idl2

;error catcher:
CATCH, theError
IF theError NE 0 THEN BEGIN
CATCH, /cancel
HELP, /LAST_MESSAGE, OUTPUT=errMsg
FOR i=0, N_ELEMENTS(errMsg)-1 DO print, errMsg[i]
RETURN
ENDIF

restore,filename
b=band
b1=b[*,*,0];Red
b4=b[*,*,3];Green
b3=b[*,*,2];Blue
num=10	
device,retain=2
window,xsize=640,ysize=512,0
;display a 3-band overlay on the screen to for sample-pick
;overlay=fltarr(640,512,3)
;overlay=[[[b[*,*,0]]],[[b[*,*,1]]],[[b[*,*,2]]]]
CH1=HIST_EQUAL(b1)
CH2=HIST_EQUAL(b4)
CH3=HIST_EQUAL(b3)
overlay=COLOR_QUAN(ch1,ch2,ch3,Red,Green,Blue,COLORS=256)
tvlct,red,green,blue
tvimage,overlay
;tv,hist_equal(overlay)
;WRITE_JPEG, 'test.jpeg', TVRD(TRUE=1), TRUE=1, QUALITY=100

; pick region of interest using box_cursor
xs = 640 ; xsize for window
ys = 512 ; ysize for window

xw=10.0 ;the size of a single sample
yw=10.0

sample1=fltarr(yw,xw,num)
sample2=fltarr(yw,xw,num)	
sample3=fltarr(yw,xw,num)
sample4=fltarr(yw,xw,num)
sample5=fltarr(yw,xw,num)
sample6=fltarr(yw,xw,num)
sample7=fltarr(yw,xw,num)
sample8=fltarr(yw,xw,num)

sample_mean=fltarr(7,num)

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
print,format='(a4,i1,a15,a16,a36)','Pick',i+1,'Start Position','Size','Center Postion'
print,x0,y0,xw,yw,xcen,ycen

;get data from box with xcen,ycen as center and xw,yw as widths

img1 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,0];band 1
img2 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,1];band 2
img3 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,2];band 3
img5 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,4];band 5
img20 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,19];band 20
img31 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,30];band 31
img32 = b[xcen-newxw:xcen+newxw+1,ycen-newyw:ycen+newyw+1,31];band 32

sample1[*,*,i]=img1
sample2[*,*,i]=img2
sample3[*,*,i]=img3
sample4[*,*,i]=img5
sample5[*,*,i]=img20
sample6[*,*,i]=img31
sample7[*,*,i]=img32

print,'Mean values of slected bands:'
print,format='(a3," = ",f7.3)','B 1=',mean(img1),'B 2=',mean(img2),'B 3=',mean(img3),$
'B 5=',mean(img5),'B20=',mean(img20),'B31=',mean(img31),'B32=',mean(img32)


sample_mean[*,i]=[[mean(img1)],[mean(img2)],[mean(img3)],[mean(img5)],$
				 [mean(img20)],[mean(img31)],[mean(img32)]]

print,'----------------------------'
endif

i += 1
endrep until(aa eq 2 || i ge num)    

sample=sample_mean

if keyword_set(u) then begin 
 print,'The mean values for the samples of each band:'
 bn_num=['Band 1','Band 2','Band 3','Band 5',$
		 'Band18','Band20','Band31','Band32']
 u=fltarr(7)
 u[0]=mean(sample1)
 u[1]=mean(sample2)
 u[2]=mean(sample3)
 u[3]=mean(sample4)
 u[4]=mean(sample5)
 u[5]=mean(sample6)
 u[6]=mean(sample7)

 for i =0,6 do print,format='(a7," = ",f7.3)',bn_num[i],u[i]
endif
val_u=u

if keyword_set(std) then begin 
 print,'The Standard Deviation for the samples of each band:'
 bn_num=['Band 1','Band 2','Band 3','Band 5',$
		 'Band18','Band20','Band31','Band32']
 std=fltarr(7)
 std[0]=stddev(sample1)
 std[1]=stddev(sample2)
 std[2]=stddev(sample3)
 std[3]=stddev(sample4)
 std[4]=stddev(sample5)
 std[5]=stddev(sample6)
 std[6]=stddev(sample7)


 for i =0,6 do print,format='(a6," = ",f7.3)',bn_num[i],std[i]
endif
val_std=std

end 

;main
shay_pick_sample, 'ru2_band.sav',/u,/std,Val_std=val_Std,val_u=val_u,Sample=sample
end
