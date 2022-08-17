function [crism_rlatlon] = convert_xyz2planetocentric(xyz)

radius = sqrt(sum(xyz.^2,1));

uxyz = xyz ./ radius;
lat = asind(uxyz(3,:));

cos_lat = cosd(lat);

lon = acosd(uxyz(1,:)./cos_lat);

crism_rlatlon = cat(1,radius,lat,lon);

end