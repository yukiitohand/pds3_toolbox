function [subimg] = hirise_lazyenvireadRect_mexw(megdrdata_obj,...
   sample_offset,line_offset,samplesc,linesc,varargin)
% [subimg] = hirise_lazyenvireadRect_mexw(megdrdata_obj,...
%    sample_offset,line_offset,samplesc,linesc,varargin)
%   MEX wrapper.
% INPUTS
%   megdrdata_obj: MOLA_MEGDRdata class object
%   sample_offset, line_offset: samples and lines to be offset
%   samplesc, linesc: size of the rectangle
% OUTPUTS
%   subimg: array [linesc x samplesc]
% s
% OPTIONAL PARAMETERS
%   PRECISION: char, string; data type of the output image.
%       'double', 'single', 'raw'
%      if 'raw', the data is returned with the original data type of the
%      image.
%      (default) 'double'
%     
%      
%    

precision = 'double';
compensate_offset = true;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PRECISION'
                precision = varargin{i+1};
            case 'COMPENSATE_OFFSET'
                compensate_offset = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end


[subimg] = hirise_lazyenvireadRect_mex(megdrdata_obj.imgpath,megdrdata_obj.hdr,...
            sample_offset,line_offset,samplesc,linesc);
subimg = subimg';

switch lower(precision)
    case 'double'
        subimg = double(subimg);
    case 'single'
        subimg = single(subimg);
    case 'raw'
        
    otherwise
        error('Undefined precision %d',precision);
end

if isfield(megdrdata_obj.hdr,'data_ignore_value')
    subimg(subimg==megdrdata_obj.hdr.data_ignore_value) = nan;
end


end
