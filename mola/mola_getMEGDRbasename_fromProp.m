function [basenameMEGDR] = mola_getMEGDRbasename_fromProp(prop)
% [basenameMEGDR] = mola_getMEGDRbasename_fromProp(prop)
%  Input Parameters
%   prop: struct storing properties
%    'map_type_id'
%    'latitude_ul'
%    'NS'
%    'longitude_ul'
%    'map_resol_id'
%    'version' 
%  Output Parameters
%   basename: string, like
%     MEGkxxdyyyrv.IMG
%        k: A for areoid, C for counts, R for radius, T for topography
%       xx: latitude of pixel in upper left corner of the image
%        d: N for north latitude, S for south
%      yyy: longitude of the pixel in the upper left corner of the image (0-360 east)
%        r: map resolution in pixels per degree, e.g.
%                C =   4 pix/deg    E =  16 pix/deg
%                F =  32 pix/deg    G =  64 pix/deg    H = 128 pix/deg
%        v: version letter.

map_type_id  = prop.map_type_id;
latitude_ul  = prop.latitude_ul;
NS           = prop.NS;
longitude_ul = prop.longitude_ul;
map_resol_id = prop.map_resol_id;
vr           = prop.version;

if isnumeric(latitude_ul)
    latitude_ul = sprintf('%02d',latitude_ul);
end

if isnumeric(longitude_ul)
    longitude_ul = sprintf('%03d',longitude_ul);
end


basenameMEGDR = sprintf('MEG%1s%s%1s%s%1s%1s',map_type_id,latitude_ul,NS,longitude_ul,map_resol_id,vr);

end