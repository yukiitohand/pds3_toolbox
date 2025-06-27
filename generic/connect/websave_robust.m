function [err] = websave_robust(filename,url,options)
% websave_robust(filename,url,options)
%  robust version of websave. If the downloading stops with an error, 
%  resume where it stops.
%  Input
%   filename: local file url
%   url:  remote url
%   options: weboptions

options_tmp = options;

err = 0;
flg_fin   = 0;
n_failure = 0;
max_trial = 5;

filename_ori = filename;

while ~(flg_fin || n_failure > max_trial)
    try
        websave(filename,url,options_tmp);
        flg_fin = 1;
    catch ME
        switch ME.identifier
            case 'MATLAB:webservices:HTTP404StatusCodeError'
                fprintf(2, '%s:\n%s', ME.identifier, ME.message);
                flg_fin = 1;
                err = 1;
                delete(filename);
            otherwise
                fprintf(2,ME.getReport());
                fprintf(2, '%s:\n%s', ME.identifier, ME.message);
                file_info = dir(filename);
                file_size_cur = file_info.bytes;
                range_val = sprintf('bytes=%d-',file_size_cur);
                % resume_byte_pos
                options_tmp.HeaderFields = {'Range',range_val };
                fprintf('download stopped with an error at bytes=%d. Resuming ...\n',file_size_cur);
                
                % Change the file name and resume downloading from the bytes
                % specified by the Range field.
                % saving to another file.
                n_failure = n_failure + 1;
                filename = sprintf('%s-%02d',filename_ori,n_failure);
        end
        
    end
end

if n_failure>0
    % If you experienced several failures in downloading, combine them at
    % the end.
    fid = fopen(filename_ori,'a+');
    for n=1:n_failure
        filename = sprintf('%s-%02d',filename_ori,n);
        fidn = fopen(filename,'r');
        fwrite(fid,fread(fidn));
        fclose(fidn);
        delete(filename);
    end
    fclose(fid);
end

if n_failure >= max_trial
    error('Maximum number of trials is reached. Download failed.');
end

end

