function [hdr_info] = hirise_lbl2hdr(lbl_info)
% [hdr_info] = hirise_lbl2hdr(lbl_info)
%   extract header information (envi format) from HiRISE LABEL struct
%  Input Parameters
%   lbl_info: struct of LABEL file
%  Output Parameters
%   hdr_info: struct of header in envi format, if no image is found, [] is
%             returend.

% [ obj_image ] = find_OBJECT_FILE_IMAGE( lbl_info );

obj_image = lbl_info.OBJECT_IMAGE;

if isempty(obj_image)
    hdr_info = [];
else
    hdr_info = [];
    hdr_info.samples = obj_image.LINE_SAMPLES;
    hdr_info.lines = obj_image.LINES;
    hdr_info.bands = obj_image.BANDS;
    hdr_info.interleave = 'bsq';
    hdr_info.header_offset = lbl_info.RECORD_BYTES*(lbl_info.POINTER_IMAGE-1);
    
    switch upper(obj_image.SAMPLE_TYPE)
        case 'PC_REAL'
            hdr_info.data_type = 4;
            hdr_info.byte_order = 0;
        case 'MSB_UNSIGNED_INTEGER'
            hdr_info.byte_order = 1;
            switch obj_image.SAMPLE_BITS
                case 16
                    hdr_info.data_type = 12;
                case 8
                    hdr_info.data_type = 1;
                otherwise
                    error('Undefined "img_obj.SAMPLE_BITS"');
            end
        otherwise
            error('The data type: %s is not supported.',obj_image.SAMPLE_TYPE);
    end

    
    if isfield(obj_image,'BAND_STORAGE_TYPE')
        switch upper(obj_image.BAND_STORAGE_TYPE)
            case 'LINE_INTERLEAVED'
                hdr_info.interleave = 'bil';
            case 'BAND_SEQUENTIAL'
                hdr_info.interleave = 'bsq';
            otherwise
                error('The interleave: %s is not supported.',...
                    obj_image.BAND_STORAGE_TYPE);
        end
    end
    
    
    if isfield(obj_image,'BAND_NAME')
        hdr_info.band_names = obj_image.BAND_NAME;
    end

    % export map projection information
    obj_map = lbl_info.OBJECT_IMAGE_MAP_PROJECTION;
    if isempty(obj_map)
        
    else
        [map_info,projection_info,coordinate_system_string] = hirise_get_map_info(obj_map);
        hdr_info.map_info = map_info;
        hdr_info.projection_info = projection_info;
        hdr_info.coordinate_system_string = coordinate_system_string;
        hdr_info.x = map_info.dx*((1:hdr_info.samples)-map_info.image_coords(1))+map_info.mapx;
        hdr_info.y = map_info.dy*(map_info.image_coords(2)-(1:hdr_info.lines))+map_info.mapy;
    end
    
    

end




end