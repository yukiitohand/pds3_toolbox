function [r] = mgsmola_get_radius(lat,lon,varargin)

% MAP TYPE ID
%  A for areoid, C for counts, R for radius, T for topography
map_type_id  = 'R'; 

% map resolution in pixels per degree, e.g.
%   C =   4 pix/deg    E =  16 pix/deg
%   F =  32 pix/deg    G =  64 pix/deg    H = 128 pix/deg
map_resol_id = 'E'; % 1/16 degree per pixel (about 3.705km)
vr = 'B';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MAP_RESOLUTION'
                map_resol_id = varargin{i+1};
            case 'MAP_TYPE'
                map_type_id  = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end


prop_mola = mola_createMEGDRbasename('MAP_TYPE_ID', map_type_id, ...
    'MAP_RESOLUTION', map_resol_id, 'VERSION', vr);

if abs(lat)>87
    fprintf('It is better to use polar file.\n');
end

switch upper(map_resol_id)
    case {'C','E','F'}
        prop_mola.latitude_ul  = 90;
        prop_mola.NS           = 'N';
        prop_mola.longitude_ul = 0;
        
    case 'G'
        prop_mola.NS = 'N';
        prop_mola.latitude_ul = 90 * (lat>0);
        prop_mola.longitude_ul = 180 * (lon>180);

    case 'H'
        if abs(lat)>88
            error('latitude: %f deg is not included.');
        end
        prop_mola.latitude_ul  = 44 * ceil(lat/44);
        prop_mola.longitude_ul = 90 * floor(lon/90);
        if prop_mola.longitude_ul<0
            prop_mola.NS = 'S';
        else
            prop_mola.NS = 'N';
        end

    otherwise
        error('Currently RESOLUTION ID: %s is not supported.',map_resol_id);
end

basename_mola = mola_getMEGDRbasename_fromProp(prop_mola);

molaRdata = MOLA_MEGTRdata(basename_mola,'');
if lon<0, lon = 360+lon; end
x = round(molaRdata.lon2x(lon));
y = round(molaRdata.lat2y(lat));
r = molaRdata.lazyEnviRead(x,y) + molaRdata.lbl.OBJECT_IMAGE.OFFSET;
r = r/1000;

end