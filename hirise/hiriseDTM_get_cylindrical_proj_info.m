function [proj_info,longitudes,latitudes] = hiriseDTM_get_cylindrical_proj_info(lbl)

map_resol = lbl.OBJECT_IMAGE_MAP_PROJECTION.MAP_RESOLUTION.value;
S0 = lbl.OBJECT_IMAGE_MAP_PROJECTION.SAMPLE_PROJECTION_OFFSET.value;
first_pxl = lbl.OBJECT_IMAGE_MAP_PROJECTION.SAMPLE_FIRST_PIXEL;
last_pxl  = lbl.OBJECT_IMAGE_MAP_PROJECTION.SAMPLE_LAST_PIXEL;
ctr_lon = lbl.OBJECT_IMAGE_MAP_PROJECTION.CENTER_LONGITUDE.value;
longitudes = ((first_pxl:last_pxl) - S0) ./ map_resol + ctr_lon;

wmost_lon = (first_pxl-0.5 - S0) ./ map_resol + ctr_lon;
emost_lon = (last_pxl+0.5 - S0) ./ map_resol + ctr_lon;

L0 = lbl.OBJECT_IMAGE_MAP_PROJECTION.LINE_PROJECTION_OFFSET.value;
first_pxl = lbl.OBJECT_IMAGE_MAP_PROJECTION.LINE_FIRST_PIXEL;
last_pxl  = lbl.OBJECT_IMAGE_MAP_PROJECTION.LINE_LAST_PIXEL;
ctr_lat = lbl.OBJECT_IMAGE_MAP_PROJECTION.CENTER_LATITUDE.value;
latitudes = (L0-(first_pxl:last_pxl)) ./ map_resol + ctr_lat;

max_lat = (L0-first_pxl+0.5) ./ map_resol + ctr_lat;
min_lat = (L0-last_pxl-0.5) ./ map_resol + ctr_lat;

proj_info = [];
proj_info.lat1 = latitudes(1);
proj_info.lon1 = longitudes(1);
proj_info.rdlat = map_resol;
proj_info.rdlon = map_resol;
proj_info.lon_range = [wmost_lon,emost_lon];
proj_info.lat_range = [max_lat,min_lat];

end