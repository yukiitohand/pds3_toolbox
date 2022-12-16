function [xpc,ypc,zpc] = mars_latlon2xyzpc(pclats,lons,rMars_e,rMars_p)
% [xpc,ypc,zpc] = mars_latlon2xyzpc(pclats,lons,rMars_e,rMars_p)
% convert lat-lon latitude to planetocentric xyz coordinate. Radius is
% assumed to be equal to ellipsoid.

% radii = cspice_bodvrd( 'MARS', 'RADII', 3 )*1000;
% rMars_e = radii(1); rMars_p = radii(3);


sin_pclats = sind(pclats);
r = rMars_e ./ sqrt(1+((rMars_e/rMars_p)^2-1)*sin_pclats.^2);

cos_pclats = cosd(pclats);
xpc = r .* cos_pclats.*cosd(lons);
ypc = r .* cos_pclats.*sind(lons);
zpc = r .* sin_pclats;

end