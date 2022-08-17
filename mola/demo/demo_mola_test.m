
pds_geosciences_node_setup;
crism_init;
crism_info = CRISMObservation('b6f1','sensor_id','L');

DEdata = CRISMDDRdata(crism_info.info.basenameDDR,crism_info.info.dir_ddr);
DEdata.readimg();
TRRRAdata = CRISMdata(crism_info.info.basenameRA,crism_info.info.dir_trdr);
TRRRAdata.readHKT();

sclk = [TRRRAdata.hkt.data.EXPOSURE_SCLK_S] + [TRRRAdata.hkt.data.EXPOSURE_SCLK_SS]/65536;


[sclk_mean] = get_frame_sclk_mean_fromHKT(TRRRAdata.hkt);

sclk_mean_S = floor(sclk_mean);
sclk_mean_SS = round((sclk_mean-sclk_mean_S)*65536);


sclk_strt_str = cellfun(...
    @(x,y) sprintf('%d:%d',x,y),num2cell([TRRRAdata.hkt.data.EXPOSURE_SCLK_S]),...
    num2cell([TRRRAdata.hkt.data.EXPOSURE_SCLK_SS]),...
    'UniformOutput',false);

sclk_mean_str = cellfun(...
    @(x,y) sprintf('%d:%d',x,y),num2cell(sclk_mean_S),num2cell(sclk_mean_SS),...
    'UniformOutput',false);

CMdata = CRISMdata('CDR410000000000_CM0000000L_0','');
CMdata.readimg();

cmimg = squeeze(CMdata.img);

rMars_m = 3396190; % meters

mrgn_deg = 600 / (rMars_m*pi) * 180;

lat_range = [max(DEdata.ddr.Latitude.img,[],'all')+mrgn_deg, min(DEdata.ddr.Latitude.img,[],'all')-mrgn_deg];
lon_range = [min(DEdata.ddr.Longitude.img,[],'all')-mrgn_deg,max(DEdata.ddr.Longitude.img,[],'all')+mrgn_deg];

%% Get DEMdata
MSLDEMdata = MSLGaleDEMMosaic_v3('MSL_Gale_DEM_Mosaic_1m_v3_dave','/Users/yukiitoh/data/');
[img_dem,xmsldem,ymsldem] = MSLDEMdata.get_subimage_wlatlon(lon_range,lat_range);
basenameA = 'MEGA90N000EB';
molaAdata = MOLA_MEGTRdata(basenameA,'');
[imgA,xrA,yrA] = molaAdata.get_subimage_wlatlon(lon_range,lat_range,'precision','raw','compensate_offset',0);

megdr_lines = size(imgA,1); megdr_samples = size(imgA,2);
msldem_lines = size(img_dem,1); msldem_samples = size(img_dem,2);
megdr_lon0 = molaAdata.longitude(xrA(1));
megdr_lat0 = molaAdata.latitude(yrA(1));
msldem_lat0 = MSLDEMdata.latitude(ymsldem(1));
msldem_lon0 = MSLDEMdata.longitude(xmsldem(1));
msldem_dang = 1/MSLDEMdata.cylindrical_proj_info.rdlat;
megdr_dang = 1/molaAdata.cylindrical_proj_info.rdlat;
y0_lat = -(megdr_lat0 - msldem_lat0) / msldem_dang;
y0_lon = (megdr_lon0 - msldem_lon0) / msldem_dang;
ar = megdr_dang/msldem_dang;
yul = ceil(( ar * (-0.5) ) + y0_lat);
xul = ceil(( ar * (-0.5) ) + y0_lon);
ylr = floor(( ar * (megdr_lines-0.5) ) + y0_lat);
xlr = floor(( ar * (megdr_samples-0.5) ) + y0_lon);

megdr_img_u_samples = xlr-xul+1;
megdr_img_u_lines = ylr-yul+1;
megdr_img_u_lon0 = msldem_dang * xul + msldem_lon0;
megdr_img_u_lat0 = -msldem_dang * yul + msldem_lat0;

[imgA_u] = mola_megdr_upsample_int16_mex(imgA,megdr_lat0,megdr_lon0,megdr_dang,...
    megdr_img_u_samples,megdr_img_u_lines,megdr_img_u_lat0,megdr_img_u_lon0,msldem_dang);
    
% [imgA_u] = mola_megdr_upsample(imgA,megdr_lat0,megdr_lon0,megdr_dang,...
%     msldem_samples,msldem_lines,msldem_lat0,msldem_lon0,msldem_dang);
wng_sz = round((ar-1)/2);
[imgA_ua] = mola_megdr_average_mex(imgA_u,-xul,-yul,msldem_samples,msldem_lines,wng_sz);

%%