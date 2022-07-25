function [fnames_mtch,regexp_out] = naif_readDownloadBasename(basenamePtr,subdir_local,subdir_remote,dwld,varargin)
% [basename] = naif_readDownloadBasename(basenamePtr,local_dir,remote_subdir,dwld,varargin)
%    search basenames that match 'basenamePtr' in 'subdir_local' and return
%    the actual name. If nothing can be found, then download any files that
%    matches 'baenamePtr' from 'remote_subdir' depending on 'dwld' option.
%  Input Parameters
%    basenamePtr: regular expression to find a file with mathed basename.
%    subdir_local: local sub-directory path to be searched 
%    subdir_remote: remote_sudir to be searched (input to 'pds_downloader')
%    dwld: {-1, 0, 1, 2}
%          if dwld>0, then this is passed to 'pds_downloader'
%          -1: show the list of file that match the input pattern.
%  Optional input parameters
%      'MATCH_EXACT'    : binary, if basename match should be exact match
%                         or not.
%                         (default) false
%      'Overwrite'      : binary, whether or not to overwrite the image
%      'VERBOSE'        : boolean, whether or not to show the downloading
%                         operations.
%                         (default) true
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%  Output parameters
%    basename: real basename matched.

global naif_archive_env_vars
localrootDir    = naif_archive_env_vars.local_naif_archive_rootDir;
url_local_root  = naif_archive_env_vars.naif_archive_root_URL;

mtch_exact = false;
ext_ignore = true;
overwrite = 0;
verbose = true;
index_cache_update = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case 'EXT_IGNORE'
                ext_ignore = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

dir_local = joinPath(localrootDir,url_local_root,subdir_local); 

if dwld<=0
    fnamelist = dir(dir_local);
    [fnames_mtch,regexp_out] = mtch_ptrn_fnamelist(basenamePtr, ...
        [{fnamelist.name}],'exact',mtch_exact,'ext_ignore',ext_ignore);
elseif dwld>0
    [dirs,files] = naif_archive_downloader(subdir_local,...
        'Subdir_remote',subdir_remote,'BASENAMEPTRN',basenamePtr,...
        'DWLD',dwld,'overwrite',overwrite, 'VERBOSE',verbose, ...
        'INDEX_CACHE_UPDATE', index_cache_update);
    
    [fnames_mtch,regexp_out] = mtch_ptrn_fnamelist( ...
        basenamePtr,files,'exact',mtch_exact, ...
        'ext_ignore',ext_ignore);
end
end