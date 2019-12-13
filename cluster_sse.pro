; docformat = 'rst'
;+
;
; A procedure to calculate the SSE and mean values
;
; :Private:
;
; :Categories:
; Remote Sensing/ATS670
;
; :Examples:
; cluster_sse,cluster,b,u,5,SSE=sse,new_u=new_u
;
;
; :Author:
; Xuechang "Shay" Liu, UAH, xuechang at nsstc.uah.edu 
;
; :History:
; Modification History::
; First written: Mar 18, 2013
;
;−
;
Pro cluster_sse,cluster,b,u,cluster_number,SSE=sse,New_u=new_u
;+
; Description...What does this do?
;
; :Returns:
; SSE and new mean values as output keywords
;
; :Params:
; cluster : in, required, type=numerical array
;	 a 640*512 array with cluster indices
; b : in, required, type=numerical array
;	 a concatenated array of selected bands
; cluster_number : in, required, type=integer
;	 the number of the single cluster of interest
;
; :Keywords:
; SSE : out, optional, type=float
; 	the SSE of A SINGLE CLUSTER which is chosen by user by cluster_number
; New_u : out, optional, type=numerical array
; 	new computed mean values of the original cluster
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

cluster_array = [0]

cluster_ind=where(cluster eq cluster_number,count)
if count gt 0 then cluster_array=reform(b[*,cluster_ind],7,count)

SSE=0.

;SSE of a single cluster
if count gt 0 then begin
 for i = 0, (size(cluster_array))[2]-1 do begin
	SSE=SSE+(cluster_array[0,i]-u[0,cluster_number])^2+(cluster_array[1,i]-u[1,cluster_number])^2$
			+(cluster_array[2,i]-u[0,cluster_number])^2+(cluster_array[3,i]-u[3,cluster_number])^2$
			+(cluster_array[4,i]-u[4,cluster_number])^2+(cluster_array[5,i]-u[5,cluster_number])^2$
			+(cluster_array[6,i]-u[6,cluster_number])^2
 endfor
endif

new_u=fltarr((size(cluster_array))[1])
if count gt 0 then begin
 for i=0,(size(cluster_array))[1]-1 do begin
  new_u[i]=mean(cluster_array[i,*])
 endfor
endif else begin
 print,'No pixel belongs to cluster center',u[*,cluster_number]
 new_u=make_array((size(cluster_array))[1],(size(cluster_array))[1],/float,value=300) 
endelse
end

