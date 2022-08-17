function [map_info,projection_info,coordinate_system_string] = hirise_get_map_info(obj_imp)

map_projection_type = obj_imp.MAP_PROJECTION_TYPE;

switch upper(map_projection_type)
    case 'EQUIRECTANGULAR'
        switch obj_imp.A_AXIS_RADIUS.unit
            case '<KM>'
                rMars_m = obj_imp.A_AXIS_RADIUS.value * 1000;
            otherwise
                error('Not implemented for %s',obj_imp.A_AXIS_RADIUS.unit);
        end
        center_latitude = obj_imp.CENTER_LATITUDE.value;
        center_longitude = obj_imp.CENTER_LONGITUDE.value;
        
        pxl_per_deg   = obj_imp.MAP_RESOLUTION.value;
        meter_per_pxl = obj_imp.MAP_SCALE.value;
        meter_per_deg = meter_per_pxl * pxl_per_deg;
        S0 = obj_imp.SAMPLE_PROJECTION_OFFSET.value;
        L0 = obj_imp.LINE_PROJECTION_OFFSET.value;
        
        x1 = (1-S0)*meter_per_pxl + center_longitude*meter_per_deg;
        y1 = (L0-1)*meter_per_pxl + center_latitude*meter_per_deg;

        map_info = [];
        map_info.projection = map_projection_type;
        % [1,1] is considered as the center of the most upper left pixel by the 
        % class SphereEquiRectangularProj, while in ENVI, [1.5 1.5] is considered 
        % as the center of the most upper left pixel. [1 1] is the upper left
        % vertex of the upper left most pixel.
        map_info.image_coords = [1.5 1.5];
        map_info.mapx = x1;
        map_info.mapy = y1;
        map_info.dx = meter_per_pxl;
        map_info.dy = meter_per_pxl;
        map_info.datum = 'D_Sphere_Mars';
        map_info.units = 'Meters';
        
        projection_info = sprintf('{17, %f, %9.6f, %9.6f, 0.0, 0.0, D_Sphere_Mars, %s, units=Meters}',...
            rMars_m,center_latitude,center_longitude,map_projection_type);

        coordinate_system_string = {...
            sprintf('PROJCS["%s",',map_projection_type),...
            sprintf('GEOGCS["GCS_Sphere_Mars",DATUM["D_Sphere_Mars",SPHEROID["Sphere_Mars",%10.1f,0.0]],',rMars_m),...
            sprintf('PRIMEM["Reference_Meridian",%10.6f],',center_latitude),...
                    'UNIT["Degree",0.0174532925199433]],',... % this is pi/180
                    'PROJECTION["Equidistant_Cylindrical"],',...
                    'PARAMETER["False_Easting",0.0],',...
                    'PARAMETER["False_Northing",0.0],',...
            sprintf('PARAMETER["Central_Meridian",%10.6f],',center_longitude),...
                    'PARAMETER["Standard_Parallel_1",0.0],',...
                    'UNIT["Meter",1.0]]}' ... % this is probably the scale with respect to meter
            };
        coordinate_system_string = [coordinate_system_string{:}];
        
    otherwise
        error('Undefined Map_Projection_Type: %s.',map_projection_type);
end

end