function [map_resol_id] = mola_megdr_get_map_resol_id_from_resol(map_resolution)
% C =   4 pix/deg    E =  16 pix/deg
% F =  32 pix/deg    G =  64 pix/deg    H = 128 pix/deg
switch map_resolution
    case 4
        map_resol_id = 'C';
    case 16
        map_resol_id = 'E';
    case 32
        map_resol_id = 'F';
    case 64
        map_resol_id = 'G';
    case 128
        map_resol_id = 'H';
    otherwise
        error('Undefined map_resolution %d',map_resolution);
end

end