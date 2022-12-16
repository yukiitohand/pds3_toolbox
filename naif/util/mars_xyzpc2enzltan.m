function [east,north,zenith] = mars_xyzpc2enzltan(xpc,ypc,zpc,pclat_ref,lon_ref,rMars_e,rMars_p)
% [east,north,zenith] = mars_xyzpc2enzltan(xpc,ypc,zpc,lat_ref,lon_ref,rMars_e,rMars_p)
% rotate planetocentric xyz coordinate to east-north-zenith local
% tangential coordinate system

% radii = cspice_bodvrd( 'MARS', 'RADII', 3 )*1000;
% rMars_e = radii(1); rMars_p = radii(3);

% Get trigonometry of planetodetoic latitude 
tan_pclat = sind(pclat_ref) / cosd(pclat_ref);
tan_pdlat = (rMars_e/rMars_p)^2*tan_pclat;
% pdlat = atan(tan_pdlat);
cos_pdlat = 1 / sqrt(1+tan_pdlat^2);
sin_pdlat = tan_pdlat / sqrt(1+tan_pdlat^2);

% Get the coordinate.
[xpc_ref,ypc_ref,zpc_ref] = mars_latlon2xyzpc(pclat_ref,lon_ref,rMars_e,rMars_p);

xpc_d = xpc-xpc_ref;
ypc_d = ypc-ypc_ref;
zpc_d = zpc-zpc_ref;

e_east   = [-sind(lon_ref);cosd(lon_ref);0];
e_north  = [-sin_pdlat*cosd(lon_ref);-sin_pdlat*sind(lon_ref);cos_pdlat];
e_zenith = -[cos_pdlat*cosd(lon_ref);cos_pdlat*sind(lon_ref);sin_pdlat];

east   = xpc_d*e_east(1)   + ypc_d*e_east(2)   + zpc_d*e_east(3)  ;
north  = xpc_d*e_north(1)  + ypc_d*e_north(2)  + zpc_d*e_north(3) ;
zenith = xpc_d*e_zenith(1) + ypc_d*e_zenith(2) + zpc_d*e_zenith(3);

end
