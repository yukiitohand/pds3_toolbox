function [ prop ] = mola_createMEGDRbasename( varargin )
% [ prop ] = mola_createMEGDRbasename( varargin )
%   return struct of the basename of MOLA MEGDR data
%  Output
%   prop: struct storing properties
%    'map_type_id'          : (default) '(?<data_type>[acrtACRT]{1})'
%    'latitude_ul'          : (default) '(?<latitude_ul>[\d]{2})'
%    'NS'                   : (default) '(?<NS>[nsNS]{1})'
%    'longitude_ul'         : (default) '(?<longitude_ul>[\d]{3})'
%    'map_resol_id'         : (default) '(?<map_resol_id>[cefghCEFGH]{1})'
%    'version'              : (default) '(?<version>[a-zA-Z]{1})'
%
%   Optional Parameters
%    'MAP_TYPE_ID', 'LATITUDE_UL', 'NS', 'LONGITUDE_UL', 'MAP_RESOL_ID',
%    'VERSION'
% 
%  * Reference *
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


map_type_id    = '(?<map_type_id>[ACRT]{1})';
latitude_ul    = '(?<latitude_ul>[\d]{2})';
NS             = '(?<NS>[NS]{1})';
longitude_ul   = '(?<longitude_ul>[\d]{3})';
map_resol_id   = '(?<map_resol_id>[CEFGH]{1})';
vr             = '(?<version>[A-Z]{1})';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MAP_TYPE_ID'
                map_type_id = varargin{i+1};
            case 'LATITUDE_UL'
                latitude_ul = varargin{i+1};
            case 'NS'
                NS = varargin{i+1};
            case 'LONGITUDE_UL'
                longitude_ul = varargin{i+1};
            case 'MAP_RESOLUTION'
                map_resol_id = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});   
        end
    end
end

prop = [];
prop.map_type_id = map_type_id;
prop.latitude_ul = latitude_ul;
prop.NS = NS;
prop.longitude_ul = longitude_ul;
prop.map_resol_id = map_resol_id;
prop.version = vr;

end