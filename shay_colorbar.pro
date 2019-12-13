; docformat = 'rst'
;+
;
; Make a colorbar
;
; :Private:
;
; :Categories:
; Remote Sensing Research/ATS670
;
; :Examples:
; shay_colorbar,['Ash','Ass'],[0,1],Xstart=0.1,Ystart=0.1,Xend=0.9
;
; :Author:
; Xuechang "Shay" Liu, UAH, xuechang at nsstc.uah.edu 
;
; :History:
; Modification History::
; First written: March 14,2013
;
;−
;
pro shay_colorbar,ClassLabel,color_index,Xstart=xstart,Ystart=Ystart,Xend=xend,Loc=loc
;+
; To create a colorbar on current graphic window
;
;
; :Params:
; ClassLabel : in, required, type=string array
; color_index : in, required, type=numerical array
;
; :Keywords:
; Xstart : in, optional, type=float
; Ystart : in, optional, type=float
; Xend : in, optional, type=float
; Loc : in, optional, type=numerical array
;
; :Uses:
; OtherRoutines
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



if ~keyword_set(xstart) then xstart=0.2
if ~keyword_set(ystart) then ystart=0.07
if ~keyword_set(xend) then xend=0.8
if n_elements(loc) eq 0 then loc = [0.2, 0.044, 0.8, 0.096]

nc=n_elements(ClassLabel)

xse=[xstart,xend]
yse=[ystart,ystart]
xstp=float(xse[1]-xse[0])/(nc*1.)
for i=0., nc-1 do begin
 x=[xse[0]+xstp*i,xse[0]+xstp*(i+1)]
 y=[yse[0],yse[1]]
 plots,x,y,thick=30,color=color_index[i],/normal
 xyouts,xse[0]+xstp*i,yse[0]-.04,ClassLabel[i],color=11,/normal
endfor
plots, [loc[0], loc[0], loc[2], loc[2], loc[0]], $
       [loc[1], loc[3], loc[3], loc[1], loc[1]], color=11,/Normal

end











