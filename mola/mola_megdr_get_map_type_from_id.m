function [map_type,map_type_short] = mola_megdr_get_map_type_from_id(map_type_id)
% A for areoid, C for counts, R for radius, T for topography
switch upper(map_type_id)
    case 'A'
        map_type = 'AREOID_RADIUS';
        map_type_short = 'AREOID';
    case 'C'
        map_type = 'COUNTS_PER_BIN';
        map_type_short = 'COUNTS';
    case 'R'
        map_type = 'MEAN_RADIUS';
        map_type_short = 'RADIUS';
    case 'T'
        map_type = 'MEDIAN_TOPOGRAPHY';
        map_type_short = 'TOPOGRAPHY';
    otherwise
        error('Undefined map_type_id %s',map_type_id);
end

end