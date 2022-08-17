function [] = hirise_dtmimg_splitlbl(imgpath)
% [] = hirise_dtmimg_splitlbl(imgpath)
%  Separate LBL information to a file. This is intended for the HiRISE DTM
%  data. The extracted LBL information is saved in the separate file in the
%  same directory as the image file, with the extension changed to '.LBL'.
%  INPUT
%   imgpath: imgpath to the HiRISE DTM IMG data.
%  No outputs 
%   


[dirpath,basename,ext] = fileparts(imgpath);

% Case of the extension is determined depending on the extension of the img
% file.
if strcmp(upper(ext),ext)
    ext_lbl = 'LBL';
elseif strcmp(lower(ext),ext)
    ext_lbl = 'lbl';
else
    error('Weird extension %s\n',ext);
end

lblpath = joinPath(dirpath,[basename,'.' ext_lbl]);
% check the file exist or not first
if exist(lblpath,'file')
    fprintf('file would be overwritten.\n');
end

% read information from imgpath
[lbl,posend] = pds3lblread(imgpath);
lbl_region_max = lbl.RECORD_BYTES*(lbl.IMAGE-1);
fprintf('LABEL information should be stored at bytes [1 - %6d].\n',lbl_region_max);
if posend <= lbl_region_max
    fprintf('Valid LABEL information seems to be stored  [1 - %6d], whithin the record \n',posend);
else
    error('Valid LABEL information seems to be stored  [1 - %6d], out of the record. Something wrong.\n',posend);
end

% perform extracting information and saving "lblpath"
fid_in = fopen(imgpath,'r');
tmp = fread(fid_in,posend,'char*1');
fclose(fid_in);

fid_out = fopen(lblpath,'w');
fwrite(fid_out,tmp,'char*1');
fclose(fid_out);

end













