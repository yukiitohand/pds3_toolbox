function [fnames_mtch,regexp_out] = mtch_ptrn_fnamelist(fname_ptrn,fnamelist,varargin)
% [fnames_mtch,regexp_out] = mtch_ptrn_fnamelist(fname_ptrn,fnamelist,varargin)
% INPUTS
%  fname_ptrn : char/string
%  fnameList  : cell array of filenames
% OUTPUTS
%  fnames_mtch: cell array of matched fnames
%  regexp_out: cell array of the result of regexpi
% Optional Parameters
%   "MATCH_EXACT" : boolean
%     whether or not basename match should be exact match or not.
%      (default) false
% 

% if ~exist(dirpath,'dir')
%     error('%s does not exist.',dirpath);
% end

is_exact   = false;
ext_ignore = true;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'EXACT'
                is_exact = varargin{i+1};
            case 'EXT_IGNORE'
                ext_ignore = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

% if isempty(fnamelist)
%     fnames_mtch = ''; regexp_out = [];
% else
    if is_exact
        fname_ptrn = ['^' fname_ptrn '[[.][a-zA-Z]]*$'];
    end
    [regexp_out] = cellfun(@(fname) regexpi(fname,fname_ptrn,'names'), ...
        fnamelist,'UniformOutput',false);
    mtch_idxes = ~isempties(regexp_out);
    regexp_out = regexp_out(mtch_idxes);
    fnames_mtch = fnamelist(mtch_idxes);
    if isempty(fnames_mtch)
    else
        if ext_ignore
            fnames_mtch_ei = cell(1,length(fnames_mtch));
            for i=1:length(fnames_mtch)
                [~,basename,ext] = fileparts(fnames_mtch{i});
                fnames_mtch_ei{i} = basename;            
            end
            [fnames_mtch_ei,ia,ic] = unique(fnames_mtch_ei);
            fnames_mtch = fnames_mtch_ei;
            regexp_out = regexp_out(ia);
        end
        if length(fnames_mtch)==1
            fnames_mtch = fnames_mtch{1};
        end
    end
        
% end

end