PRO HDF_VD_VDATAREAD, HDFID, VDATANAME, FIELDNAME, DATA

;+
; NAME:
;    HDF_VD_VDATAREAD
;
; PURPOSE:
;    Read data from a Vdata field in a HDF file.
;
; CATEGORY:
;    HDF utilities.
;
; CALLING SEQUENCE:
;    HDF_VD_VDATAREAD, HDFID, VDATANAME, FIELDNAME, DATA
;
; INPUTS:
;    HDFID        Identifier of HDF file opened by caller with HDF_OPEN.
;    VDATANAME    Name of the Vdata.
;    FIELDNAME    Name of the field within the Vdata.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    None.
;
; OUTPUTS:
;    DATA        Named variable in which all data will be returned
;                (all records are read from the field).
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;file = 'sdsvdata.hdf'
;hdfid = hdf_open(file)
;hdf_vd_vdataread, hdfid, 'Vdata with mixed types', 'Float', data
;hdf_close, hdfid
;help, data
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: hdf_vd_vdataread.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: hdf_vd_vdataread.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Check arguments
if (n_params() ne 4) then $
  message, 'Usage: HDF_VD_VDATAREAD, HDFID, VDATANAME, FIELDNAME, DATA'
if (n_elements(hdfid) eq 0) then message, 'Argument HDFID is undefined'
if (n_elements(vdataname) eq 0) then message, 'Argument VDATANAME is undefined'
if (n_elements(fieldname) eq 0) then message, 'Argument FIELDNAME is undefined'
if (arg_present(data) eq 0) then message, 'Argument DATA cannot be modified'

;- Get index for the vdata
index = hdf_vd_find(hdfid, vdataname)
if (index eq 0) then message, $
  string(vdataname, format='("VDATANAME not found: ", a)')

;- Attach to the vdata
vdataid = hdf_vd_attach(hdfid, index)

;- Check that fieldname exists in this vdata
if (hdf_vd_fexist(vdataid, fieldname) ne 1) then begin
  hdf_vd_detach, vdataid
  message, string(fieldname, format='("FIELDNAME not found: ", a)')
endif

;- Read all records from the field
nread = hdf_vd_read(vdataid, data, fields=fieldname)

;- Detach from the vdata
hdf_vd_detach, vdataid

END


PRO HDF_SD_VARREAD, HDFID, VARNAME, DATA, _EXTRA=EXTRA_KEYWORDS

;+
; NAME:
;    HDF_SD_VARREAD
;
; PURPOSE:
;    Read data from a Scientific Data Set (SDS) variable
;    in a HDF file.
;
; CATEGORY:
;    HDF utilities.
;
; CALLING SEQUENCE:
;    HDF_SD_VARREAD, HDFID, VARNAME, DATA
;
; INPUTS:
;    HDFID       Identifier of HDF file opened by caller with HDF_SD_START.
;    VARNAME     Name of Scientific Data Set variable.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    START       Set this keyword to a vector containing the start position
;                for the read in each dimension
;                (default start position is [0, 0, ..., 0]).
;    COUNT       Set this keyword to a vector containing the number of items
;                to be read in each dimension
;                (default is to read all available data).
;    STRIDE      Set this keyword to a vector containing the sampling interval
;                along each dimension
;                (default stride vector for a contiguous read is [0, 0, ..., 0]).
;    NOREVERSE   Set the keyword to retrieve the data without transposing the
;                data from column to row order.
;
; OUTPUTS:
;    DATA        Named variable in which data will be returned
;                (degenerate dimensions are removed).
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;file = 'sdsvdata.hdf'
;hdfid = hdf_sd_start(file)
;hdf_sd_varread, hdfid, '2D integer array', data
;hdf_sd_end, hdfid
;help, data
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: hdf_sd_varread.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: hdf_sd_varread.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Check arguments
if (n_params() ne 3) then message, 'Usage: HDF_SD_VARREAD, HDFID, VARNAME, DATA'
if (n_elements(hdfid) eq 0) then message, 'Argument HDFID is undefined'
if (n_elements(varname) eq 0) then message, 'Argument VARNAME is undefined'
if (arg_present(data) eq 0) then message, 'Argument VARDATA cannot be modified'

;- Get index for this variable
index = hdf_sd_nametoindex(hdfid, varname)
if (index eq -1) then $
  message, string(varname, format='("VARNAME not found: ", a)')

;- Select the variable and read the data
varid = hdf_sd_select(hdfid, index)
hdf_sd_getdata, varid, data, _extra=extra_keywords
hdf_sd_endaccess, varid
data = reform(temporary(data))

END
PRO HDF_SD_VARWRITE, HDFID, VARNAME, DATA

;+
; NAME:
;    HDF_SD_VARWRITE
;
; PURPOSE:
;    Write data to a Scientific Data Set (SDS) variable in a HDF file.
;
; CATEGORY:
;    HDF utilities.
;
; CALLING SEQUENCE:
;    HDF_SD_VARWRITE, HDFID, VARNAME, DATA
;
; INPUTS:
;    HDFID       Identifier of HDF file opened by caller with HDF_SD_START
;                in file creation mode.
;    VARNAME     Name of Scientific Data Set variable.
;    DATA        Variable to be written to the file.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    None.
;
; OUTPUTS:
;    None.
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;file = 'test.hdf'
;hdfid = hdf_sd_start(file, /create)
;hdf_sd_varwrite, hdfid, 'test array', dist(32)
;hdf_sd_end, hdfid
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: hdf_sd_varwrite.pro,v 1.1 2006/03/07 16:49:48 gumley Exp $'

;- Check arguments
if (n_params() ne 3) then message, 'Usage: HDF_SD_VARWRITE, HDFID, VARNAME, DATA'
if (n_elements(hdfid) eq 0) then message, 'Argument HDFID is undefined'
if (n_elements(varname) eq 0) then message, 'Argument VARNAME is undefined'
if (n_elements(data) eq 0) then message, 'Argument DATA is undefined'

;- Get the dimensions and HDF data type for this variable
dims = size(data, /dimensions)
type = size(data, /type)
hdf_type = hdf_idl2hdftype(type)

;- Create the SDS variable
varid = hdf_sd_create(hdfid, varname, [dims], hdf_type=hdf_type)

;- Write the data
hdf_sd_adddata, varid, data
hdf_sd_endaccess, varid

END


FUNCTION BRIGHT_M, W, R

;+
; DESCRIPTION:
;    Compute brightness temperature given monochromatic Planck radiance.
;
; USAGE:
;    RESULT = BRIGHT_M(W, R)
;
; INPUT PARAMETERS:
;    W           Wavelength (microns)
;    R           Planck radiance (Watts per square meter per steradian
;                per micron)
;
; OUTPUT PARAMETERS:
;    BRIGHT_M    Brightness temperature (Kelvin)
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: bright_m.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: bright_m.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Constants are from "The Fundamental Physical Constants",
;- Cohen, E. R. and B. N. Taylor, Physics Today, August 1993.

;- Planck constant (Joule second)
h = 6.6260755e-34

;- Speed of light in vacuum (meters per second)
c = 2.9979246e+8

;- Boltzmann constant (Joules per Kelvin)      
k = 1.380658e-23

;- Derived constants      
c1 = 2.0 * h * c * c
c2 = (h * c) / k

;- Convert wavelength to meters
ws = 1.0e-6 * w
      
;- Compute brightness temperature
return, c2 / (ws * alog(c1 / (1.0e+6 * r * ws^5) + 1.0))

END

FUNCTION MODIS_BRIGHT, RAD, BAND, UNITS

;+
; DESCRIPTION:
;    Compute brightness temperature for an EOS-AM MODIS infrared band.
;
;    Spectral responses for each IR detector were obtained from MCST:
;    ftp://mcstftp.gsfc.nasa.gov/incoming/MCST/PFM_L1B_LUT_4-30-99
;
;    An average spectral response for each infrared band was
;    computed. The band-averaged spectral response data were used
;    to compute the effective central wavenumbers and temperature
;    correction coefficients included in this module.
;
; USAGE:
;    RESULT = MODIS_BRIGHT(RAD, BAND, UNITS)
;
; INPUT PARAMETERS:
;    RAD           Planck radiance (units are determined by UNITS)
;    BAND          MODIS IR band number (20-25, 27-36)
;    UNITS         Flag defining radiance units
;                  0 => milliWatts per square meter per steradian per
;                       inverse centimeter
;                  1 => Watts per square meter per steradian per micron
;
; OUTPUT PARAMETERS:
;    MODIS_BRIGHT  Brightness temperature (Kelvin)
;                  Note that a value of -1.0 is returned if
;                  BAND is not in range 20-25, 27-36.
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: modis_bright.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: modis_bright.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Check input parameters
if (n_params() ne 3) then $
  message, 'Usage: RESULT = MODIS_BRIGHT(RAD, BAND, UNITS)'
if (n_elements(rad) eq 0) then $
  message, 'Argument RAD is undefined'
if (n_elements(band) eq 0) then $
  message, 'Argument BAND is undefined'
if (n_elements(units) eq 0) then $
  message, 'Argument UNITS is undefined'
if (band lt 20) or (band gt 36) or (band eq 26) then $
  message, 'Argument BAND must be in the range [20-25, 27-36]'

;- BAND-AVERAGED MODIS SPECTRAL RESPONSE FUNCTIONS FOR EOS-AM
;- TEMPERATURE RANGE FOR FIT WAS  180.00 K TO  320.00 K
;- BANDS
;-   20,  21,  22,  23,
;-   24,  25,  26,  27,
;-   28,  29,  30,  31,
;-   32,  33,  34,  35,
;-   36
;- NOTE THAT BAND 26 VALUES ARE SET TO ZERO

;- Effective central wavenumber (inverse centimenters)
cwn = [$
  2.641775E+03, 2.505277E+03, 2.518028E+03, 2.465428E+03, $
  2.235815E+03, 2.200346E+03, 0.0,          1.477967E+03, $
  1.362737E+03, 1.173190E+03, 1.027715E+03, 9.080884E+02, $
  8.315399E+02, 7.483394E+02, 7.308963E+02, 7.188681E+02, $
  7.045367E+02]

;- Temperature correction slope (no units)
tcs = [$
  9.993411E-01, 9.998646E-01, 9.998584E-01, 9.998682E-01, $
  9.998819E-01, 9.998845E-01, 0.0,          9.994877E-01, $
  9.994918E-01, 9.995495E-01, 9.997398E-01, 9.995608E-01, $
  9.997256E-01, 9.999160E-01, 9.999167E-01, 9.999191E-01, $
  9.999281E-01]

;- Temperature correction intercept (Kelvin)
tci = [$
  4.770532E-01, 9.262664E-02, 9.757996E-02, 8.929242E-02, $
  7.310901E-02, 7.060415E-02, 0.0,          2.204921E-01, $
  2.046087E-01, 1.599191E-01, 8.253401E-02, 1.302699E-01, $
  7.181833E-02, 1.972608E-02, 1.913568E-02, 1.817817E-02, $
  1.583042E-02]

;- Compute brightness temperature
if (units eq 1) then begin

  ;- Radiance units are
  ;- Watts per square meter per steradian per micron
  result = (bright_m(1.0e+4 / cwn[band - 20], rad) - $
    tci[band - 20]) / tcs[band - 20]

endif else begin

  ;- Radiance units are
  ;- milliWatts per square meter per steradian per wavenumber
  result = (brite_m(cwn[band - 20], rad) - $
    tci[band - 20]) / tcs[band - 20]

endelse

;- Return result to caller
return, result

END

FUNCTION HDF_SD_VARLIST, HDFID

;+
; NAME:
;    HDF_SD_VARLIST
;
; PURPOSE:
;    Return the number and names of Scientific Data Set (SDS) variables
;    in a HDF file.
;
; CATEGORY:
;    HDF utilities.
;
; CALLING SEQUENCE:
;    RESULT = HDF_SD_VARLIST(HDFID)
;
; INPUTS:
;    HDFID       Identifier of HDF file opened by caller with HDF_SD_START.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    None.
;
; OUTPUTS:
;    An anonymous structure containing the number of SDS variables in the file,
;    and the name of each SDS variable in the file.
;    The fields in the structure are as follows:
;    NVARS       Number of SDS variables in the file (0 if none were found).
;    VARNAMES    Array of SDS variable names ('' if none were found).
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;file = 'sdsvdata.hdf'
;hdfid = hdf_sd_start(file)
;result = hdf_sd_varlist(hdfid)
;hdf_sd_end, hdfid
;help, result, /structure
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: hdf_sd_varlist.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: hdf_sd_varlist.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Check arguments
if (n_params() ne 1) then message, 'Usage: RESULT = HDF_SD_VARLIST(HDFID)'
if (n_elements(hdfid) eq 0) then message, 'Argument HDFID is undefined'

;- Set default return values
nvars = 0
varnames = ''

;- Get number of SDS variables and global attributes
hdf_sd_fileinfo, hdfid, nvars, ngatts

;- Get SDS variable names
if (nvars gt 0) then begin
  varnames = strarr(nvars)
  for index = 0, nvars - 1 do begin
    varid = hdf_sd_select(hdfid, index)
    hdf_sd_getinfo, varid, name=name
    hdf_sd_endaccess, varid
    varnames[index] = name
  endfor
endif

;- Return the result
return, {nvars:nvars, varnames:varnames}

END

FUNCTION HDF_SD_ATTINFO, HDFID, VARNAME, ATTNAME, GLOBAL=GLOBAL

;+
; NAME:
;    HDF_SD_ATTINFO
;
; PURPOSE:
;    Return the name, type, and data for an attribute associated with
;    an individual Scientific Data Set (SDS) variable in a HDF file,
;    or a global attribute in a HDF file.
;
; INPUTS:
;    HDFID       Identifier of HDF file opened by caller with HDF_SD_START.
;    VARNAME     Name of variable to examine (ignored if GLOBAL keyword set).
;    ATTNAME     Name of attribute.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    GLOBAL      If set, information about a global attribute is returned.
;
; OUTPUTS:
;    An anonymous structure containing the name, type, and data for the
;    requested attribute.
;    The fields in the structure are as follows:
;    NAME    Name of the attribute ('' if attribute or variable was not found).
;    TYPE    Attribute data type ('' if attribute or variable was not found).
;    DATA    Attribute data (-1 if attribute or variable was not found).
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;file = 'sdsvdata.hdf'
;hdfid = hdf_sd_start(file)
;result = hdf_sd_attinfo(hdfid, '', 'message')
;help, result, /structure
;result = hdf_sd_attinfo(hdfid, '2D integer array', 'units')
;help, result, /structure
;hdf_sd_end, hdfid
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: hdf_sd_attinfo.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: hdf_sd_attinfo.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Check arguments
if (n_params() ne 3) then $
  message, 'Usage: RESULT = HDF_SD_ATTDIR(HDFID, VARNAME, ATTNAME)'
if (n_elements(hdfid) eq 0) then message, 'Argument HDFID is undefined'
if (n_elements(varname) eq 0) then message, 'Argument VARNAME is undefined'
if (n_elements(attname) eq 0) then message, 'Argument ATTNAME is undefined'

;- Set default return values
name = ''
type = ''
data = -1

;- Get attribute information
if (keyword_set(global)) then begin

  ;- Get information about a global attribute
  attindex = hdf_sd_attrfind(hdfid, attname)
  if (attindex ge 0) then hdf_sd_attrinfo, hdfid, attindex, $
    name=name, type=type, data=data
      
endif else begin

  ;- Get information about a variable attribute
  varindex = hdf_sd_nametoindex(hdfid, varname)
  if (varindex ge 0) then begin
    varid = hdf_sd_select(hdfid, varindex)
    attindex = hdf_sd_attrfind(varid, attname)
    if (attindex ge 0) then hdf_sd_attrinfo, varid, attindex, $
      name=name, type=type, data=data
    hdf_sd_endaccess, varid
  endif
  
endelse

;- Return result to caller
return, {name:name, type:type, data:data}

END
FUNCTION HDF_SD_VARINFO, HDFID, VARNAME

;+
; NAME:
;    HDF_SD_VARINFO
;
; PURPOSE:
;    Return information about a Scientific Data Set (SDS) variable
;    in a HDF file.
;
; CATEGORY:
;    HDF utilities.
;
; CALLING SEQUENCE:
;    RESULT = HDF_SD_VARINFO(HDFID, VARNAME)
;
; INPUTS:
;    HDFID       Identifier of HDF file opened by caller with HDF_SD_START.
;    VARNAME     Name of Scientific Data Set variable.
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    None.
;
; OUTPUTS:
;    An anonymous structure containing information about the SDS.
;    The fields in the structure are as follows:
;    NAME        Name of the variable ('' if variable not found)
;    NDIMS       Number of dimensions (-1 if variable not found)
;    DIMS        Array of dimension sizes (-1 if variable not found)
;    DIMNAMES    Array of dimension names ('' if variable not found)
;    TYPE        Variable data type ('' if variable not found)
;
; OPTIONAL OUTPUTS:
;    None
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
; EXAMPLE:
;
;file = 'sdsvdata.hdf'
;hdfid = hdf_sd_start(file)
;result = hdf_sd_varinfo(hdfid, '2D integer array')
;hdf_sd_end, hdfid
;help, result, /structure
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: hdf_sd_varinfo.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: hdf_sd_varinfo.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;- Check arguments
if (n_params() ne 2) then message, 'Usage: RESULT = HDF_SD_VARINFO(HDFID)'
if (n_elements(hdfid) eq 0) then message, 'Argument HDFID is undefined'
if (n_elements(varname) eq 0) then message, 'Argument VARNAME is undefined'

;- Set default return values
name     = ''
ndims    = -1
dims     = -1
dimnames = ''
type     = ''

;- Get variable information
varindex = hdf_sd_nametoindex(hdfid, varname)
if (varindex ge 0) then begin

  ;- Select the variable and get name, dimension, and type information
  varid = hdf_sd_select(hdfid, varindex)
  hdf_sd_getinfo, varid, name=name, ndims=ndims, dims=dims, type=type
  
  ;- Get dimension names
  if (ndims ge 1) then begin
    dimnames= strarr(ndims)
    for dimindex = 0, ndims - 1 do begin
      dimid = hdf_sd_dimgetid(varid, dimindex)
      hdf_sd_dimget, dimid, name=dimname
      dimnames[dimindex] = dimname
    endfor
  endif
  
  ;- Deselect the variable
  hdf_sd_endaccess, varid
  
endif

;- Return result to caller
return, {name:name, ndims:ndims, dims:dims, dimnames:dimnames, type:type}

END

PRO MODIS_L1B_READ, FILENAME, BAND, IMAGE, $
  RAW=RAW, REFLECTANCE=REFLECTANCE, TEMPERATURE=TEMPERATURE, $
  CORRECTED=CORRECTED,SOLARZENITH=solzen, VIEWZENITH=vza,$
  AREA=AREA, UNITS=UNITS, PARAMETER=PARAMETER, $
  SCANTIME=SCANTIME, MIRROR=MIRROR, LATITUDE=LATITUDE, LONGITUDE=LONGITUDE, $
  VALID_INDEX=VALID_INDEX, VALID_COUNT=VALID_COUNT, VALID_RANGE=VALID_RANGE, $
  INVALID_INDEX=INVALID_INDEX, INVALID_COUNT=INVALID_COUNT, RANGE=RANGE, $
  MISSING=MISSING, START=START, COUNT=COUNT, SCALE_FACTOR=SCALE_FACTOR
  
;+
; NAME:
;    MODIS_LEVEL1B_READ
;
; PURPOSE:
;    Read a single band from a MODIS Level 1B HDF product file at
;    1000, 500, or 250 m resolution.
;
;    The output image is available in the following units (Radiance is default):
;    RAW DATA:    Raw data values as they appear in the HDF file
;    RADIANCE:    Radiance (Watts per square meter per steradian per micron)
;    REFLECTANCE: Reflectance (Bands 1-19 and 26; *without* solar zenith correction)
;    TEMPERATURE: Brightness Temperature (Bands 20-25 and 27-36, Kelvin)
;
;    This procedure uses only HDF calls (it does *not* use HDF-EOS),
;    and only reads from SDS and Vdata arrays (it does *not* read ECS metadata).
;
; CATEGORY:
;    MODIS utilities.
;
; CALLING SEQUENCE:
;    MODIS_LEVEL1B_READ, FILENAME, BAND, IMAGE
;
; INPUTS:
;    FILENAME       Name of MODIS Level 1B HDF file
;    BAND           Band number to be read
;                   (1-36 for 1000 m, 1-7 for 500 m, 1-2 for 250m)
;                   (Use 13, 13.5, 14, 14.5 for 13lo, 13hi, 14lo, 14hi)
;
; OPTIONAL INPUTS:
;    None.
;
; KEYWORD PARAMETERS:
;    RAW            If set, image data are returned as raw HDF values
;                   (default is to return image data as radiance).
;    REFLECTANCE    If set, image data for bands 1-19 and 26 only are
;                   returned as reflectance *without* solar zenith angle correction
;                   (default is to return image data as radiance).
;    TEMPERATURE    If set, image data for bands 20-25 and 27-36 only are
;                   returned as brightness temperature
;                   (default is to return image data as radiance).
;    AREA           A four element vector specifying the area to be read,
;                   in the format [X0,Y0,NX,NY]
;                   (default is to read the entire image).
;    UNITS          On return, a string describing the image units.
;    PARAMETER      On return, a string describing the image (e.g. 'Radiance').
;    SCANTIME       On return, a vector containing the start time of each scanline
;                   (SDPTK TAI seconds).
;    MIRROR         On return, a vector containing the mirror side for each scanline
;    LATITUDE       On return, an array containing the reduced resolution latitude
;                   data for the entire granule (degrees, every 5th line and pixel).
;    LONGITUDE      On return, an array containing the reduced resolution longitude
;                   data for the entire granule (degrees, every 5th line and pixel).
;    VALID_INDEX    On return, a vector containing the 1D indexes of pixels which
;                   are within the 'valid_range' attribute values.
;    VALID_COUNT    On return, the number of pixels which
;                   are within the 'valid_range' attribute values.
;    INVALID_INDEX  On return, a vector containing the 1D indexes of pixels which
;                   are not within the 'valid_range' attribute values.
;    INVALID_COUNT  On return, the number of pixels which
;                   are not within the 'valid_range' attribute values.
;    RANGE          On return, a 2-element vector containing the minimum and 
;                   maximum data values within the 'valid range'.
;    MISSING        If set, defines the value to be inserted for missing data when
;returning
;                   the result in radiance, reflectance, or brightness temperature
;units
;                   (default is -1.0).
;    
; OUTPUTS:
;    IMAGE          A two dimensional array of image data in the requested units.
;
; OPTIONAL OUTPUTS:
;    None.
;
; COMMON BLOCKS:
;    None
;
; SIDE EFFECTS:
;    None.
;
; RESTRICTIONS:
;    Requires IDL 5.0 or higher (square bracket array syntax).
;
;    Requires the following HDF procedures by Liam.Gumley@ssec.wisc.edu:
;    HDF_SD_ATTINFO      Get information about an attribute
;    HDF_SD_ATTLIST      Get list of attribute names
;    HDF_SD_VARINFO      Get information about an SDS variable
;    HDF_SD_VARLIST      Get a list of SDS variable names
;    HDF_SD_VARREAD      Read an SDS variable
;    HDF_VD_VDATAINFO    Get information about a Vdata
;    HDF_VD_VDATALIST    Get list of Vdata names
;    HDF_VD_VDATAREAD    Read a Vdata field
;
;    Requires the following Planck procedures by Liam.Gumley@ssec.wisc.edu:
;    MODIS_BRIGHT        Compute MODIS brightness temperature
;    BRIGHT_M            Compute brightness temperature (EOS radiance units)
;
; EXAMPLES:
;
;; These examples require the IMDISP image display procedure, available from
;; http://cimss.ssec.wisc.edu/~gumley/imdisp.html
;
;; Read band 1 in radiance units from a 1000 m resolution file
;file = 'MOD021KM.A2000062.1020.002.2000066023928.hdf'
;modis_level1b_read, file, 1, band01
;imdisp, band01, margin=0, order=1
;
;; Read band 31 in temperature units from a 1000 m resolution file
;file = 'MOD021KM.A2000062.1020.002.2000066023928.hdf'
;modis_level1b_read, file, 31, band31, /temperature
;imdisp, band31, margin=0, order=1, range=[285, 320]
;
;; Read a band 1 subset in reflectance units from a 500 m resolution file
;file = 'MOD02HKM.A2000062.1020.002.2000066023928.hdf'
;modis_level1b_read, file, 1, band01, /reflectance, area=[1000, 1000, 700, 700]
;imdisp, band01, margin=0, order=1
;
;; Read band 6 in reflectance units from a 1000 m resolution file, 
;; and screen out invalid data when scaling
;file = 'MOD021KM.A2000062.1020.002.2000066023928.hdf'
;modis_level1b_read, file, 6, band06, /reflectance, valid_index=valid_index
;range = [min(band06[valid_index]), max(band06[valid_index])]
;imdisp, band06, margin=0, order=1, range=range
;
; MODIFICATION HISTORY:
; Liam.Gumley@ssec.wisc.edu
; http://cimss.ssec.wisc.edu/~gumley
; $Id: modis_l1b_read.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $
;
; Copyright (C) 1999, 2000 Liam E. Gumley
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;-

rcs_id = '$Id: modis_l1b_read.pro,v 1.1 2003/06/30 20:27:21 gumley Exp $'

;-------------------------------------------------------------------------------
;- CHECK INPUT
;-------------------------------------------------------------------------------

;- Check arguments
if (n_params() ne 3) then $
  message, 'Usage: MODIS_LEVEL1B_READ, FILENAME, BAND, IMAGE'

if (n_elements(filename) eq 0) then $
  message, 'Argument FILENAME is undefined'

if (n_elements(band) eq 0) then $
  message, 'Argument BAND is undefined'

if (arg_present(image) ne 1) then $
  message, 'Argument IMAGE cannot be modified'

if (n_elements(area) gt 0) then begin
  if (n_elements(area) ne 4) then $
    message, 'AREA must be a 4-element vector of the form [X0,Y0,NX,NY]'
endif

if (n_elements(missing) eq 0) then missing = -1.0

;-------------------------------------------------------------------------------
;- CHECK FOR VALID MODIS L1B HDF FILE, AND GET FILE TYPE (1km, 500 m, or 250 m)
;-------------------------------------------------------------------------------

;- Check that file exists
;if ((findfile(filename))[0] eq '') then $
;  message, 'FILENAME was not found => ' + filename
  
;- Get expanded filename
openr, lun, filename, /get_lun
fileinfo = fstat(lun)
free_lun, lun

;- Check that file is HDF
if (hdf_ishdf(fileinfo.name) ne 1) then $
  message, 'FILENAME is not HDF => ' + fileinfo.name

;- Get list of SDS arrays
sd_id = hdf_sd_start(fileinfo.name)
varlist = hdf_sd_varlist(sd_id)
hdf_sd_end, sd_id

;- Locate image arrays
index = where(varlist.varnames eq 'EV_1KM_Emissive', count_1km)
index = where(varlist.varnames eq 'EV_500_RefSB',    count_500)
index = where(varlist.varnames eq 'EV_250_RefSB',    count_250)
case 1 of
  (count_1km eq 1) : filetype = 'MOD021KM'
  (count_500 eq 1) : filetype = 'MOD02HKM'
  (count_250 eq 1) : filetype = 'MOD02QKM'
  else : message, 'FILENAME is not MODIS Level 1B HDF => ' + fileinfo.name
endcase  

;-------------------------------------------------------------------------------
;- CHECK BAND NUMBER, AND KEYWORDS WHICH DEPEND ON BAND NUMBER
;-------------------------------------------------------------------------------

;- Check band number
case filetype of
  'MOD021KM' : if (band lt 1) or (band gt 36) then $
    message, 'BAND range is 1-36 for this MODIS type => ' + filetype
  'MOD02HKM' : if (band lt 1) or (band gt 7) then $
    message, 'BAND range is 1-7 for this MODIS type => ' + filetype
  'MOD02QKM' : if (band lt 1) or (band gt 2) then $
    message, 'BAND range is 1-2 for this MODIS type => ' + filetype
endcase

;- Check for invalid request for reflectance units
if ((band ge 20) and (band ne 26)) and keyword_set(reflectance) then $
  message, 'REFLECTANCE units valid for bands 1-19, 26 only'

;- Check for invalid request for temperature units
if ((band le 19) or (band eq 26)) and keyword_set(temperature) then $
  message, 'TEMPERATURE units valid for bands 20-25, 27-36 only'

;-------------------------------------------------------------------------------
;- SET VARIABLE NAME FOR IMAGE DATA
;-------------------------------------------------------------------------------

case filetype of

  ;- 1 km resolution data
  'MOD021KM' : begin
    case 1 of
      (band ge  1 and band le  2) : sds_name = 'EV_250_Aggr1km_RefSB'
      (band ge  3 and band le  7) : sds_name = 'EV_500_Aggr1km_RefSB'
      (band ge  8 and band le 19) : sds_name = 'EV_1KM_RefSB'
      (band eq 26)                : sds_name = 'EV_Band26'
      (band ge 20 and band le 36) : sds_name = 'EV_1KM_Emissive'
    endcase
  end
  
  ;- 500 m resolution data
  'MOD02HKM' : begin
    case 1 of
      (band ge  1 and band le  2) : sds_name = 'EV_250_Aggr500_RefSB'
      (band ge  3 and band le  7) : sds_name = 'EV_500_RefSB'
    endcase
  end
  
  ;- 250 m resolution data
  'MOD02QKM' : sds_name = 'EV_250_RefSB'

endcase

;-------------------------------------------------------------------------------
;- SET ATTRIBUTE NAMES FOR IMAGE DATA
;-------------------------------------------------------------------------------

;- Set names of scale, offset, and units attributes
if keyword_set(reflectance) then begin
  scale_name  = 'reflectance_scales'
  offset_name = 'reflectance_offsets'
  units_name  = 'reflectance_units'
  parameter   = 'Reflectance'
endif else begin
  scale_name  = 'radiance_scales'
  offset_name = 'radiance_offsets'
  units_name  = 'radiance_units'
  parameter   = 'Radiance'
endelse

;-------------------------------------------------------------------------------
;- OPEN THE FILE IN SDS MODE
;-------------------------------------------------------------------------------

sd_id = hdf_sd_start(fileinfo.name)

;-------------------------------------------------------------------------------
;- CHECK BAND ORDER AND GET BAND INDEX
;-------------------------------------------------------------------------------

if (band ne 26) then begin

  ;- Get the list of band numbers for this SDS array
  att_info = hdf_sd_attinfo(sd_id, sds_name, 'band_names')
  if (att_info.name eq '') then message, 'Attribute not found: band_names'
  band_list = str_sep(att_info.data, ',')
  
  ;- Convert the requested band number to a string
  band_name = strcompress(long(band), /remove_all)
  if (band eq 13) then band_name = '13lo'
  if (band eq 14) then band_name = '14lo'
  if (abs(band - 13.5) lt 0.01) then band_name = '13hi'
  if (abs(band - 14.5) lt 0.01) then band_name = '14hi'
  
  ;- Get the index of the band
  band_index = (where(band_name eq band_list))[0]
  if (band_index lt 0) then message, 'Requested band number was not found'
  
endif else begin

  band_index = 0
  
endelse

;-------------------------------------------------------------------------------
;- READ IMAGE DATA
;-------------------------------------------------------------------------------

;- Get information about the image array
varinfo = hdf_sd_varinfo(sd_id, sds_name)
if (varinfo.name eq '') then $
  message, 'Image array was not found: ' + sds_name
npixels_across = varinfo.dims[0]
npixels_along  = varinfo.dims[1]

;- Set start and count values
start = [0L, 0L, band_index]
count = [npixels_across, npixels_along, 1L]
if (band eq 26) then begin
  start = start[0 : 1]
  count = count[0 : 1]
endif

;- Use AREA keyword if it was supplied
if (n_elements(area) eq 4) then begin
  start[0] = (long(area[0]) > 0L) < (npixels_across - 1L)
  start[1] = (long(area[1]) > 0L) < (npixels_along  - 1L)
  count[0] = (long(area[2]) > 1L) < (npixels_across - start[0])
  count[1] = (long(area[3]) > 1L) < (npixels_along  - start[1])
endif

;- Read the image array (hdf_sd_varread not used because of bug in IDL 5.1)
var_id = hdf_sd_select(sd_id, hdf_sd_nametoindex(sd_id, sds_name))
hdf_sd_getdata, var_id, image, start=start, count=count
hdf_sd_endaccess, var_id

;-------------------------------------------------------------------------------
;- READ IMAGE ATTRIBUTES
;-------------------------------------------------------------------------------

;- Read scale attribute
att_info = hdf_sd_attinfo(sd_id, sds_name, scale_name)
if (att_info.name eq '') then message, 'Attribute not found: ' + scale_name
scale = att_info.data

;- Read offset attribute
att_info = hdf_sd_attinfo(sd_id, sds_name, offset_name)
if (att_info.name eq '') then message, 'Attribute not found: ' + offset_name
offset = att_info.data

;- Read units attribute
att_info = hdf_sd_attinfo(sd_id, sds_name, units_name)
if (att_info.name eq '') then message, 'Attribute not found: ' + units_name
units = att_info.data

;- Read valid range attribute
valid_name = 'valid_range'
att_info = hdf_sd_attinfo(sd_id, sds_name, valid_name)
if (att_info.name eq '') then message, 'Attribute not found: ' + valid_name
valid_range = att_info.data

;- Read latitude and longitude arrays
if arg_present(latitude) then hdf_sd_varread, sd_id, 'Latitude', latitude
if arg_present(longitude) then hdf_sd_varread, sd_id, 'Longitude', longitude
hdf_sd_varread, sd_id, 'SolarZenith', tmpsza
solzen=congrid(tmpsza,5*n_elements(tmpsza(*,0))-1,5*n_elements(tmpsza(0,*)))

hdf_sd_varread, sd_id, 'SensorZenith', tempvza
vza=congrid(tempvza,5*n_elements(tempvza(*,0))-1,5*n_elements(tempvza(0,*)))

;-------------------------------------------------------------------------------
;- CLOSE THE FILE IN SDS MODE
;-------------------------------------------------------------------------------

hdf_sd_end, sd_id

;-------------------------------------------------------------------------------
;- READ VDATA INFORMATION
;-------------------------------------------------------------------------------

;- Open the file in vdata mode
hdfid = hdf_open(fileinfo.name)

;- Read scan start time (SDPTK TAI seconds) and mirror side
vdataname = 'Level 1B Swath Metadata'
hdf_vd_vdataread, hdfid, vdataname, 'EV Sector Start Time', scantime
hdf_vd_vdataread, hdfid, vdataname, 'Mirror Side', mirror

;- Close the file in vdata mode
hdf_close, hdfid

;- Resample and extract the scantime
scantime = rebin(scantime, npixels_along, /sample)
scantime = scantime[start[1]: start[1] + count[1] - 1]

;- Resample and extract the mirror side
mirror = rebin(mirror, npixels_along, /sample)
mirror = mirror[start[1]: start[1] + count[1] - 1]

;-------------------------------------------------------------------------------
;- PERFORM OPERATIONS IN SCALED INTEGER UNITS
;-------------------------------------------------------------------------------

;- Convert from unsigned short integer to long integer
image = temporary(image) and 65535L
valid_range = valid_range and 65535L

;- Get valid/invalid indexes and counts
valid_check = (image ge valid_range[0]) and (image le valid_range[1])
invalid_index = where(valid_check eq 0B, invalid_count)
if (arg_present(valid_index) or arg_present(valid_count)) then $
  valid_index = where(valid_check eq 1B, valid_count)

;- If raw HDF values were requested, return to caller
if keyword_set(raw) then begin
  units = 'Unsigned 16-bit integers'
  parameter = 'Raw HDF Values'
  if arg_present(range) then range = valid_range
  return
endif

;- Replace saturated pixels in bands 1-5 with maximum scaled integer
sat_count = 0
if (band le 5) then begin
  sat_check = (image eq 65533) or (image eq 65528)
  sat_index = where(sat_check eq 1B, sat_count)
  if (sat_count ge 1) then image[sat_index] = valid_range[1]
endif

;-------------------------------------------------------------------------------
;- CONVERT IMAGE TO REQUESTED OUTPUT UNITS
;-------------------------------------------------------------------------------

;- Convert image to unscaled values
image = scale[band_index] * (temporary(image) - offset[band_index])
valid_range = scale[band_index] * (valid_range - offset[band_index])
scale_factor = scale[band_index]

;- Convert radiance to brightness temperature for IR bands
if keyword_set(temperature) then begin
  image = modis_bright(temporary(image), band, 1)
  valid_range = modis_bright(valid_range, band, 1)
  units = 'Kelvin'
  parameter = 'Brightness Temperature'
endif

;- Set non-saturated invalid values to missing value
if (invalid_count gt 0) then begin
  if (sat_count eq 0) then begin
    missing_index = invalid_index
  endif else begin
    missing_index = where(valid_check eq 0B and sat_check eq 0B, missing_count)
  endelse
  if (missing_index[0] ne -1L) then image[missing_index] = missing
endif

;- Set non-finite values to missing value
nonfinite_index = where(finite(image) ne 1, nonfinite_count)
if (nonfinite_count gt 0) then image[temporary(nonfinite_index)] = missing

;- Get data range (min/max of non-missing image values)
if arg_present(range) then begin
  nonmissing_index = where(image ne missing, nonmissing_count)
  if (nonmissing_count gt 0) then begin
    minval = min(image[temporary(nonmissing_index)], max=maxval)
    range = [minval, maxval]
  endif else begin
    range = [missing, missing]
  endelse
endif

if keyword_set(reflectance) then image=image/cos(!dtor*0.01*solzen)
END

