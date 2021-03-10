function [map_resolution] = mola_megdr_get_map_resolution_from_id(map_resol_id)
% C =   4 pix/deg    E =  16 pix/deg
% F =  32 pix/deg    G =  64 pix/deg    H = 128 pix/deg
switch upper(map_resol_id)
    case 'C'
        map_resolution = 4;
    case 'E'
        map_resolution = 16;
    case 'F'
        map_resolution = 32;
    case 'G'
        map_resolution = 64;
    case 'H'
        map_resolution = 128;
    otherwise
        error('Undefined map_resol_id %s',map_resol_id);
end

end