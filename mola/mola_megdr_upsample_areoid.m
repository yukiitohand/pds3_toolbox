function [imgA_ua,img_dem,xmsldem,ymsldem] = mola_megdr_upsample_areoid(...
    molaAdata,MSLDEMdata,xrange,yrange,unit_range)
% [imgA_ua,img_dem,xmsldem,ymsldem] = mola_megdr_upsample_areoid(...
%     molaAdata,MSLDEMdata,lat_range,lon_range)
%  
% INPUTS
%   molaAdata : MOLA_MEGTRdata obj, areoid data.
%   MSLDEMdata: MSLDEMdata
%   xrange : 2-lemgth vector,   
%   yrange : 2-length vector,   
%   unit_range: string, {'Degree','Pixels'}
%    'Degree'
%       xrange [westernmost longitude, easternmost longitude], in degree
%       yrange [maximum latitude,minimum latitude], in degree
%    'Pixels'
%       xrange: pixel range in the horizontal direction
%       yrange: pixel range in the vertical direction
% 
% OUTPUTS
%   imgA_ua : mola areoid upsample to msldem image resolution
%   img_dem : msldem image 
%   xmsldem : sample index range of the img_dem
%   ymsldem : line index range of the img_dem
%   

switch upper(unit_range)
    case 'DEGREE'
        % Read areoid data given latitude and longitude range
        lon_range = xrange; lat_range = yrange;
        [imgA,xrA,yrA] = molaAdata.get_subimage_wlatlon(lon_range,lat_range,...
            'MARGIN',1,'precision','raw','compensate_offset',0);
        [img_dem,xmsldem,ymsldem] = MSLDEMdata.get_subimage_wlatlon(...
            lon_range,lat_range,'MARGIN',0);
    case 'PIXELS'
        % Read areoid data given MSLDEM pixel range
        xmsldem = xrange; ymsldem = yrange;
        [img_dem] = MSLDEMdata.get_subimage_wPixelRange(xrange,yrange);
        lon_range = MSLDEMdata.proj_info.get_lon_range(xrange);
        lat_range = MSLDEMdata.proj_info.get_lat_range(yrange);
        [imgA,xrA,yrA] = molaAdata.get_subimage_wlatlon(lon_range,lat_range,...
            'MARGIN',1,'precision','raw','compensate_offset',0);
    otherwise
        error('Undefined UNIT_RANGE %s',unit_range);
end

% 
megdr_lines = size(imgA,1); megdr_samples = size(imgA,2);
msldem_lines = size(img_dem,1); msldem_samples = size(img_dem,2);
megdr_lon1 = molaAdata.proj_info.get_longitude(xrA(1));
megdr_lat1 = molaAdata.proj_info.get_latitude(yrA(1));
msldem_lat1 = MSLDEMdata.proj_info.get_latitude(ymsldem(1));
msldem_lon1 = MSLDEMdata.proj_info.get_longitude(xmsldem(1));
msldem_dang = 1/MSLDEMdata.proj_info.rdlat; % <DEGREES/PIXEL>
megdr_dang  = 1/molaAdata.proj_info.rdlat;  % <DEGREES/PIXEL>

% Determine the grid for the upsampled mola image. The pixels needs to
% align with the MSLDEM pixels, so we count the pixels from 
% (msldem_lon1, msldem_lat1)
% (x1_lon,y1_lon) represents the shift from (msldem_lon1, msldem_lat1) to 
% (megdr_lon1, megdr_lat1), which is the center of the upper left corner
% megdr pixels. 
% ( -0.5*ar + x1_lon, -0.5*ar + y1_lat) is the shift from 
% (msldem_lon1, msldem_lat1) to the upper left vertex of the upper left
% corner pixel of megdr data. The upper left corner pixel of the upsampled
% image would be created by using the function "ceil", brining the pixel
% inside the loaded MOLA subimage. 
y1_lat = -(megdr_lat1 - msldem_lat1) / msldem_dang;
x1_lon =  (megdr_lon1 - msldem_lon1) / msldem_dang;
ar = megdr_dang/msldem_dang;
yul = ceil( y1_lat + ar * (-0.5) );
xul = ceil( x1_lon + ar * (-0.5) );
% Same for the lower right corner pixel. This time, floor is used to bring
% the pixel inside the loaded MOLA subimage.
ylr = floor( y1_lat + ar * (megdr_lines-0.5)  );
xlr = floor( x1_lon + ar * (megdr_samples-0.5));

megdr_img_u_samples = xlr-xul+1;
megdr_img_u_lines   = ylr-yul+1;
megdr_img_u_lon0    = msldem_lon1 + msldem_dang * xul;
megdr_img_u_lat0    = msldem_lat1 - msldem_dang * yul;
[imgA_u] = mola_megdr_upsample_int16_mex(...
    imgA,megdr_lat1,megdr_lon1,megdr_dang,...
    megdr_img_u_samples,...
    megdr_img_u_lines,...
    megdr_img_u_lat0,...
    megdr_img_u_lon0,...
    msldem_dang);
    
% [imgA_u] = mola_megdr_upsample(imgA,megdr_lat0,megdr_lon0,megdr_dang,...
%     msldem_samples,msldem_lines,msldem_lat0,msldem_lon0,msldem_dang);
wng_sz = round((ar-1)/2);
[imgA_ua] = mola_megdr_average_mex(imgA_u,-xul,-yul,...
    msldem_samples,msldem_lines,wng_sz);

end