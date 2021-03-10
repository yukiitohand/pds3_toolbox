indpath = '/Volumes/LaCie5TB/data/pds-geosciences.wustl.edu/mgs/mgs-m-mola-5-megdr-l3-v1/mgsl_300x/index/';
lbl = pds3lblread(joinPath(indpath,'INDEX.LBL'));
[ tabdata,tabcolinfo2,tabcolinfo_names ] = pds3TABread(joinPath(indpath,'INDEX.TAB'),lbl.OBJECT_INDEX_TABLE);


%%
crism_init;
obs_id = 'B6F1';

%Load reference SOC products and its derived products.
crism_obs = CRISMObservation(obs_id,'sensor_id','S');
TRR3datasetB6F1 = CRISMTRRdataset(crism_obs.info.basenameIF,'');
DEdataB6F1 = CRISMDDRdata(crism_obs.info.basenameDDR,'');
DEdataB6F1.readimg();
TRR3datasetB6F1.trr3if.load_basenamesCDR(); 
TRR3datasetB6F1.trr3ra.load_basenamesCDR();
% GLTdataB6F1 = crism_create_glt_equirectangular_v2(...
%     DEdataB6F1,TRR3datasetB6F1.trr3ra,...
%     'RANGE_LATD',[],'RANGE_LOND',[],'Dst_Lmt_Param',3,'Pixel_Size',18,...
%     'GLT_VERSION',4,'suffix','gale_B6F1_18m','force',0,'skip_ifexist',0,...
%     'save_file',0);

rMars_m = 3396190; % meters

mrgn_deg = 500 / (rMars_m*pi) * 180;

lat_range = [max(DEdataB6F1.ddr.Latitude.img,[],'all')+mrgn_deg, min(DEdataB6F1.ddr.Latitude.img,[],'all')-mrgn_deg];
lon_range = [min(DEdataB6F1.ddr.Longitude.img,[],'all')-mrgn_deg,max(DEdataB6F1.ddr.Longitude.img,[],'all')+mrgn_deg];



%%
MSLDEMdata = MSLGaleDEMMosaic_v3('MSL_Gale_DEM_Mosaic_1m_v3_dave','/Users/yukiitoh/data/');

[img_dem,xmsldem,ymsldem] = MSLDEMdata.get_subimage_wlatlon(lon_range,lat_range);

% lon_range = [MSLDEMdata.lbl.OBJECT_IMAGE_MAP_PROJECTION.WESTERNMOST_LONGITUDE.value MSLDEMdata.lbl.OBJECT_IMAGE_MAP_PROJECTION.EASTERNMOST_LONGITUDE.value];
% lat_range = [MSLDEMdata.lbl.OBJECT_IMAGE_MAP_PROJECTION.MINIMUM_LATITUDE.value MSLDEMdata.lbl.OBJECT_IMAGE_MAP_PROJECTION.MAXIMUM_LATITUDE.value];

%%
basenameT = 'MEGT00N090HB';
basenameR = 'MEGR00N090HB';
basenameA = 'MEGA90N000EB';

molaTdata = MOLA_MEGTRdata(basenameT,'');
molaRdata = MOLA_MEGTRdata(basenameR,'');
molaAdata = MOLA_MEGTRdata(basenameA,'');

[imgT,xrT,yrT] = molaTdata.get_subimage_wlatlon(lon_range,lat_range);
% imgT = molaTdata.readimg();

[imgR,xrR,yrR] = molaRdata.get_subimage_wlatlon(lon_range,lat_range,'precision','double','compensate_offset',0);
% imgR = molaRdata.readimg();

[imgA,xrA,yrA] = molaAdata.get_subimage_wlatlon(lon_range,lat_range,'precision','double','compensate_offset',0);
% imgA = molaAdata.readimg();

imgAc = imgR-imgT;

% figure; imagx/esc(imgA); set(gca,'DataAspectRatio',[1 1 1]);
% figure; imagesc(imgAc); set(gca,'DataAspectRatio',[1 1 1]);

isv_mola2 = ImageStackView({},'Ydir','normal','XY_COORDINATE_SYSTEM','NorthEast');

isv_mola2.add_layer(molaRdata.hdr.x(xrR),molaRdata.hdr.y(yrR),imgR,'name','radius');
isv_mola2.add_layer(molaTdata.hdr.x(xrT),molaTdata.hdr.y(yrT),imgT,'name','topo');
% isv_mola2.add_layer(imgT,'name','topo');
% isv_mola2.add_layer(imgA,'name','areoid');
isv_mola2.add_layer(molaTdata.hdr.x(xrT),molaTdata.hdr.y(yrT),imgAc,'name','R-T');
isv_mola2.add_layer(molaAdata.hdr.x(xrA),molaAdata.hdr.y(yrA),imgA,'name','A');
isv_mola2.add_layer(MSLDEMdata.hdr.x(xmsldem),MSLDEMdata.hdr.y(ymsldem),img_dem,'name','msldem');
isv_mola2.add_layer(hsidata_projB6F1.GLTdata.hdr.easting([1 end]),hsidata_projB6F1.GLTdata.hdr.northing([1 end]),hsidata_projB6F1.RGBProjImage.CData_Scaled,'name','b6f1');

isv_mola2.Update_ImageAxes_LimHomeAuto();
isv_mola2.Update_ImageAxes_LimHome();
isv_mola2.Update_axim_aspectR();
isv_mola2.Restore_ImageAxes2LimHome();

