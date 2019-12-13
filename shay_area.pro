Function shay_area,dind

restore,'extract_vza_lat.sav'
  h=705.D
  re=6370.
  beta=atan(1D/h)
  
  latr=latr*!DtoR
  vzar=vzar*!DtoR
  
  theta=dblarr(640,512)
  theta[dind]=vzar[dind]
  phi=dblarr(640,512)
  phi[dind]=latr[dind]
  
  pc=beta*(h+re*(1-cos(phi)))*(1./cos(theta))*(1./cos(theta+phi))
  pa=beta*(h+re*(1-cos(phi)))*(1./cos(phi))
  
  area=(1./cos(theta))^3
tot_area=total(area[dind])
;print,tot_area
return,tot_area

end
cloud_ind=where(img eq 0, c1)
ocean_ind=where(img eq 1, c2)
soil_ind=where(img eq 2, c3)
veg_ind=where(img eq 3, c4)
smoke_ind=where(img eq 4, c5)

a=dblarr(1,5)
a[0]=shay_area(cloud_ind)
a[1]=shay_area(ocean_ind)
a[2]=shay_area(soil_ind)
a[3]=shay_area(veg_ind)
a[4]=shay_area(smoke_ind)
c=shay_area(cloud_ind)
;print,total(c[cloud_ind])
;print,transpose([c1,c2,c3,c4,c5])

print,a
end




