FUNCTION read_mod14, infile
;*** READ IN MOD/MYD14 Level 2 FIRE PIXEL .hdf FORMAT FILES


;*** EXTRACT DATE AND TIME INFORMATION FROM FILENAME
qqqq=strsplit(infile, '/', /extract)
nn = n_elements(qqqq)
qqqq2=strsplit(qqqq[nn-1], '.', /extract)


product=qqqq2[0]
year=FIX(strmid(qqqq2[1],1,4))
jday=FIX(strmid(qqqq2[1],5,7))
hour=FIX(strmid(qqqq2[2],0,2))
minute=FIX(strmid(qqqq2[2],2,2))
version=qqqq2[3]
temp=julian_day(FIX(year), 99, FIX(jday))
month=temp[1]
day=temp[2]

;*** EXTRACT META DATA
;fileid=hdf_open(infile,/read)
;vdataid=hdf_vd_find(fileid,strcompress('metadata'))
;FOR ii=0, 50 DO BEGIN
; hdf_vd_getinfo, vdname, ii, name=name
; print, name
;ENDFOR
;hdf_vd_detach, vdname

;*** Get the number AND NAMES of SDSs in the file
sdsfileid = hdf_sd_start(infile,/read)
hdf_sd_fileinfo,sdsfileid,numsds,ngatt

;MODIS 14 PRODUCTS
sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'fire mask'))
hdf_sd_getdata,sds_id,fire_mask
hdf_sd_endaccess,sds_id

sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'algorithm QA'))
hdf_sd_getdata,sds_id,algorithm_qa
hdf_sd_endaccess,sds_id

fires=where(fire_mask[*,*] GE 7, fct)

IF fct GT 0 THEN BEGIN
	sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_latitude'))
	hdf_sd_getdata,sds_id,lat
	hdf_sd_endaccess,sds_id

	sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_longitude'))
	hdf_sd_getdata,sds_id,lon
	hdf_sd_endaccess,sds_id

	sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_confidence'))
	hdf_sd_getdata,sds_id,confidence
	hdf_sd_endaccess,sds_id

	sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_T21')) ;Kelvins
        hdf_sd_getdata,sds_id,ch21_tb_fire
        hdf_sd_endaccess,sds_id

        sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_T31')) ;Kelvins
        hdf_sd_getdata,sds_id,ch31_tb_fire
        hdf_sd_endaccess,sds_id

        sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_T21')) ;Kelvins
        hdf_sd_getdata,sds_id,ch21_tb_back
        hdf_sd_endaccess,sds_id

        sds_id = hdf_sd_select(sdsfileid, hdf_sd_nametoindex(sdsfileid,'FP_T31')) ;Kelvins
        hdf_sd_getdata,sds_id,ch31_tb_back
        hdf_sd_endaccess,sds_id

ENDIF ELSE BEGIN
	lat=-999
	lon=-999
	confidence=-999
	ch21_tb_fire=-999
        ch31_tb_fire=-999
        ch21_tb_back=-999
        ch31_tb_back=-999
ENDELSE

hdf_sd_end, sdsfileid
;hdf_close, fileid

;*** WRITE DATA TO STRUCTURE
result={$
	product:product, $
	version:version, $
	fire_ct:fct, $
	year:year,$
	month:month,$
	day:day,$
	jday:jday,$
	hour:hour, $
	minute:minute, $
	fire_lat:lat, $
	fire_lon:lon, $
	fire_mask:fire_mask, $
	algorithm_qa:algorithm_qa, $
        ch21_tb_fire:ch21_tb_fire, $
        ch31_tb_fire:ch31_tb_fire, $
        ch21_tb_back:ch21_tb_back, $
        ch31_tb_back:ch31_tb_back, $
	confidence:confidence}

RETURN, result
END
