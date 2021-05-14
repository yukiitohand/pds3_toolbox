function websave_robust(filename,url,options)
% websave_robust(filename,url,options)
%  robust version of websave. If the downloading stops, restart where it
%  stops.
%  Input
%   filename: local file url
%   url:  remote url
%   options: weboptions

options_tmp = options;

flg_fin = 0;

while ~flg_fin
    try
        websave(filename,url,options_tmp);
        flg_fin = 1;
    catch
        file_info = dir(filename);
        file_size_cur = file_info.bytes;
        fprintf('download stopped with an error at bytes=%d\n',file_size_cur);
        range_val = sprintf('bytes=%d-',file_size_cur);
        % resume_byte_pos
        options_tmp.HeaderFields = {'Range',range_val };
        websave(filename,url,options_tmp);
    end
end

end

