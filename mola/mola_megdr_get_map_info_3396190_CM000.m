function [map_info,projection_info,coordinate_system_string] = mola_megdr_get_map_info_3396190_CM000(lbl)

map_projection_type = lbl.OBJECT_IMAGE_MAP_PROJECTION.MAP_PROJECTION_TYPE;

switch upper(map_projection_type)
    case 'SIMPLE CYLINDRICAL'
        % projecting onto 'Mars_Equirectangular_clon0'. This should be
        % straightforward.
        map_projection_type_tar = 'Mars_Equirectangular_clon0';
        
        % although it is used 3396km in the file, convertng to north east
        % in meters using 3396190 with the latitude and longitude
        % information for compatibility with other data.
        rMars_m = 3396190; %<m>
        
        % central meridian longitude is set to 0 deg.
        ctr_lon = lbl.OBJECT_IMAGE_MAP_PROJECTION.CENTER_LONGITUDE.value;
        ctr_lat = lbl.OBJECT_IMAGE_MAP_PROJECTION.CENTER_LATITUDE.value;
        center_latitude_tar  = 0;
        center_longitude_tar = 0;
        
        pxl_per_deg = lbl.OBJECT_IMAGE_MAP_PROJECTION.MAP_RESOLUTION.value;
        meter_per_deg = rMars_m * pi/180;
        meter_per_pxl = meter_per_deg / pxl_per_deg;
        S0 = lbl.OBJECT_IMAGE_MAP_PROJECTION.SAMPLE_PROJECTION_OFFSET;
        pxlS1 = lbl.OBJECT_IMAGE_MAP_PROJECTION.SAMPLE_FIRST_PIXEL;
        L0 = lbl.OBJECT_IMAGE_MAP_PROJECTION.LINE_PROJECTION_OFFSET;
        pxlL1 = lbl.OBJECT_IMAGE_MAP_PROJECTION.LINE_FIRST_PIXEL;
        
        x1 = ((pxlS1-S0)/pxl_per_deg + ctr_lon-center_longitude_tar) * meter_per_deg;
        y1 = ((L0-pxlL1)/pxl_per_deg + ctr_lat-center_latitude_tar) * meter_per_deg;

        map_info = [];
        map_info.projection = map_projection_type_tar;
        map_info.image_coords = [pxlS1 pxlL1];
        map_info.mapx = x1;
        map_info.mapy = y1;
        map_info.dx = meter_per_pxl;
        map_info.dy = meter_per_pxl;
        map_info.datum = 'D_Sphere_Mars';
        map_info.units = 'Meters';
        
        projection_info = sprintf('{17, %f, %9.6f, %9.6f, 0.0, 0.0, D_Sphere_Mars, %s, units=Meters}',...
            rMars_m,center_latitude_tar,center_longitude_tar,map_projection_type_tar);

        coordinate_system_string = {...
            sprintf('PROJCS["%s",',map_projection_type_tar),...
            sprintf('GEOGCS["GCS_Sphere_Mars",DATUM["D_Sphere_Mars",SPHEROID["Sphere_Mars",%10.1f,0.0]],',rMars_m),...
            sprintf('PRIMEM["Reference_Meridian",%10.6f],',center_latitude_tar),...
                    'UNIT["Degree",0.0174532925199433]],',... % this is pi/180
                    'PROJECTION["Equidistant_Cylindrical"],',...
                    'PARAMETER["False_Easting",0.0],',...
                    'PARAMETER["False_Northing",0.0],',...
            sprintf('PARAMETER["Central_Meridian",%10.6f],',center_longitude_tar),...
                    'PARAMETER["Standard_Parallel_1",0.0],',...
                    'UNIT["Meter",1.0]]}' ... % this is probably the scale with respect to meter
            };
        coordinate_system_string = [coordinate_system_string{:}];
        
    otherwise
        error('Undefined Map_Projection_Type: %s.',map_projection_type);
end

end