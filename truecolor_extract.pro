; docformat = 'rst'
;+
;
; This preocedure is to display a Modis AQUA L1B file as a truecolor image and write out as a tif file.
; Extract a box of 640*512 of interest
;
; :Private:
;
; :Categories:
; ATS509 Final Project
;
; :Examples:
; truecolor_extract,'THE_NAME_OF_THE_HDF_FILE_WITHOUT_EXTENSION'
;
;
; :Author:
; Xuechang Liu, UAH
;
; :History:
; First written: Dec 4, 2012
;
;−
;
PRO truecolor_extract_readbn,CH,FILENAME
;+
; This is a helper procedure that reads in a binary file
;
;
; :Params:
; CH : in, required, type=numerical array
; FILENAME : in, required, type=string
;
;−

OPENR,LUN,FILENAME,/GET_LUN
READU,LUN,CH
FREE_LUN,LUN
END

PRO truecolor_extract_colors,CH1,CH2,CH3,IMAGEFILENAME
;+
; A helper procedure to make three band overlay and save as 'eps' file.
;
;
; :Params:
; CH1,CH2,CH3 : in, required, type=type
; IMAGEFILENAME : in, required, type=string
;
;
;−

;Create palette and color indices
NX=1354
NY=2030
extract=bytarr(640,512)

;Scale and histogram equalized each channel from 0~255
CH1=HIST_EQUAL(CH1)
CH2=HIST_EQUAL(CH2)
CH3=HIST_EQUAL(CH3)
;Save the image as .eps file
PS_START, XSIZE=6.4*1.5, YSIZE=5.12*1.5, /INCHES, /ENCAPSULATED, FILE='extract_smoke.eps', $
CHARSIZE=1, /NOMATCH,XOFFSET=0.5,YOFFSET=0.5,/COLOR,BITS=8

;Create palette and color indices
RESULT=COLOR_QUAN(CH1,CH2,CH3,R,G,B,COLORS=256)
extract=result[450:1089,200:711]
TVLCT,R,G,B
TV,extract

PS_END

END

PRO truecolor_extract, FILE
;+
; The main procedure to import file and produce image and write out .tif file
;
; :Params:
; FILE : in, required, type=string
;
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

;Check parameter
IF ~FILE THEN MESSAGE, 'Please input a correct filename!'
;keep the backing store for all the IDL graphics windows
;DEVICE, RETAIN=2

;Define input file
INPFIL=FILE+'.'
EXT=['EV_250_Aggr1km_RefSB','EV_500_Aggr1km_RefSB']

;Define the size of image
NX=1354
NY=2030
REF250=UINDGEN(NX,NY,2)
REF500=UINDGEN(NX,NY,5)
;Read in data using the first helper routine
truecolor_extract_readbn,REF250,INPFIL+EXT[0]
truecolor_extract_readbn,REF500,INPFIL+EXT[1]

;Define the color arrays
RED=FLTARR(NX,NY)
GREEN=FLTARR(NX,NY)
BLUE=FLTARR(NX,NY)
;WINDOW,/FREE,XSIZE=NX,YSIZE=NY

;Assign the channels' data into the arrays
;Use reverse to reverse columns
RED = REVERSE(REF250[*,*,0]) ; BAND1
GREEN = REVERSE(REF500[*,*,1]) ; BAND4
BLUE = REVERSE(REF500[*,*,0]) ; BAND3




;Make true color image plot
truecolor_extract_colors,RED,GREEN,BLUE,INPFIL

;Save the 3-band array as .tif image
SET_PLOT,'X'
DEVICE,RETAIN=2
TRUECLR=BYTARR(640,512,3)

;reverse rows for tiff file  
TRUECLR[*,*,0]=(REVERSE(BYTSCL(RED*1.0),2))[450:1089,(2030-711):(2030-200)]
TRUECLR[*,*,1]=(REVERSE(BYTSCL(GREEN*1.0),2))[450:1089,(2030-711):(2030-200)]
TRUECLR[*,*,2]=(REVERSE(BYTSCL(BLUE*1.0),2))[450:1089,(2030-711):(2030-200)]
TV, TRUECLR, TRUE=3, ORDER=1
WRITE_TIFF,'Smoke_extract.tif',TRUECLR,PLANARCONFIG=2
END

truecolor_extract,'MYD021KM.A2011200.0220.005.2011200155505'
end
