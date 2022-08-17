function [prop] = mola_getProp_basenameMEGDR(basenameMEGDR,varargin)
% [prop] = mola_getProp_basenameMEGDR(basenameMEGDR,varargin)
%   Get properties from the basename of MOLA MEGDR data
%  Input Parameters
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
%  Output Parameters
%   prop: struct storing properties
%    'map_type_id'
%    'latitude_ul'
%    'NS'
%    'longitude_ul'
%    'map_resol_id'
%    'version' 

[ prop_ori ] = mola_createMEGDRbasename();
[basenameptrn] = mola_getMEGDRbasename_fromProp(prop_ori);

prop = regexpi(basenameMEGDR,basenameptrn,'names');

if ~isempty(prop)
    prop.latitude_ul  = str2num(prop.latitude_ul);
    prop.longitude_ul = str2num(prop.longitude_ul);
end


end