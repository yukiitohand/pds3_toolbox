function [map_type_id] = mola_megdr_get_map_type_id_from_map_type(map_type)
% A for areoid, C for counts, R for radius, T for topography
switch upper(map_type)
    case {'AREOID_RADIUS','AREOID'}
        map_type_id = 'A';
    case {'COUNTS_PER_BIN','COUNTS'}
        map_type_id = 'C';
    case {'MEAN_RADIUS','RADIUS'}
        map_type_id = 'R';
    case {'MEDIAN_TOPOGRAPHY','TOPOGRAPHY'}
        map_type_id = 'T';
    otherwise
        error('Undefined map_type %s',map_type);
end

end