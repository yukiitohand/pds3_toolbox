function [basename,fname_wext] = extractMatchedBasename_v2(basenamePtr,fnamelist,varargin)
% [basename] = extractMatchedBasename_v2(basenamePtr,fnamelist,varargin)
%   match the pattern to filenames in fnamelist
%
%  INPUTS
%    basenamePtr: pattern input for regexpi
%    fnamelist  : cell array of filenames (with or without extensions)
%  OUTPUTS
%    basename: string or cell array unique list of matched basenames (no extension)
%    fname_wext: cell array, all the file names with different extension
%  Optional Parameters
%      'MATCH_EXACT'    : binary, if basename match should be exact match
%                         or not.
%                         (default) false

is_exact = false;
celloutput = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'EXACT'
                is_exact = varargin{i+1};
            case 'CELLOUTPUT'
                celloutput = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end


if isempty(fnamelist)
    basename = {}; fname_wext = {};
else
    if is_exact
        basenamePtr = ['^' basenamePtr '[[.][a-zA-Z]]*$'];
    end
    matching = ~cellfun('isempty',regexpi(fnamelist,basenamePtr,'ONCE'));
    if sum(matching)>0
        fname_wext = fnamelist(matching);
        basenameList = cell(1,length(fname_wext));
        for i=1:length(fname_wext)
            [~,basename,ext] = fileparts(fname_wext{i});
            basenameList{i} = basename;            
        end
        basename = unique(basenameList);
        if ~celloutput && length(basename)==1
            basename = basename{1};
        end
    else
        basename = {}; fname_wext = {};
    end
end
end