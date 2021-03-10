function [fname_slctd,vr_slctd] = spice_get_kernel(fname_ptrn,varargin)
% [fname_slctd,vr_slctd] = spice_get_kernel(fname_ptrn,varargin)
%  raw level function for interfacing getting the spice kernel files.
% INPUTS
%  fname_ptrn : char/string, needs to have (?<version>\d+)
%  dirpath    : char/string, directory path for evaluating 
% OUTPUTS
%  fname_slctd : char/string, fname for the latest version
%  vr_slctd    : double, version number
subdir_local  = '';
subdir_remote = '';
dwld = 0;
mtch_exact = false;
ext_ignore = true;
force      = 0;
outfile    = '';
overwrite  = 0;
get_latest = false;
index_cache_update = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'SUBDIR_LOCAL'
                subdir_local = varargin{i+1};
            case 'SUBDIR_REMOTE'
                subdir_remote = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case 'EXT_IGNORE'
                ext_ignore = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'GET_LATEST'
                get_latest = varargin{i+1};
                
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end


if ~contains(fname_ptrn,'?<version>')
    error('fname_ptrn is invalid. Needs to have ''?<version>'' ');
end

% if ~exist(dirpath,'dir')
%     error('%s does not exist.',dirpath);
% end

[fnames_mtch,regexp_out] = naif_readDownloadBasename(fname_ptrn, ...
    subdir_local,subdir_remote,dwld, ...
    'ext_ignore',ext_ignore,'match_exact',mtch_exact, ...
    'force',force,'out_file',outfile,'overwrite',overwrite, ...
    'INDEX_CACHE_UPDATE',index_cache_update);
regexp_out = [regexp_out{:}];
if isempty(regexp_out)
    fname_slctd = []; vr_slctd = [];
else
    fname_slctd = fnames_mtch;
    vrs = str2double({regexp_out.version});
    if get_latest
        [vr_slctd,i_lvr] = max(vrs);
        i_lvr = find(vrs==vr_slctd);
        if iscell(fnames_mtch)
            if length(i_lvr)==1
                fname_slctd = fnames_mtch{i_lvr};
            else
                fname_slctd = fnames_mtch(i_lvr);
            end
        elseif ischar(fnames_mtch)
            fname_slctd = fnames_mtch;
        end
    else
        fname_slctd = fnames_mtch;
        vr_slctd    = vrs;
    end
end

end