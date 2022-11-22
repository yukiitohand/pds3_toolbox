function [fnames_mtch,regexp_out] = spicekrnl_readDownloadBasename(basenamePtr,subdir_local,subdir_remote,dwld,varargin)
% [basename] = spicekrnl_readDownloadBasename(basenamePtr,local_dir,remote_subdir,dwld,varargin)
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

global spicekrnl_env_vars
localrootDir    = spicekrnl_env_vars.local_SPICEkernel_archive_rootDir;
url_local_root  = spicekrnl_env_vars.url_local_root;
no_remote      = spicekrnl_env_vars.no_remote;
if isfield(spicekrnl_env_vars,'dir_tmp')
    dir_tmp = spicekrnl_env_vars.dir_tmp;
else
    dir_tmp = [];
end

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

if no_remote && dwld>0
    error(['No remote server is defined in spicekrnl_env_vars.\n' ...
           ['dwld=%d >0 is invalid. dwld can be either 0 or -1 for no_remote=1.'] ...
          ], dwld);
end

dir_local = joinPath(localrootDir,url_local_root,subdir_local); 

if dwld<=0
    if no_remote && ~isempty(dir_tmp)
        cache_dir = fullfile(dir_tmp,url_local_root,subdir_local);
        index_cache_fname = 'index.txt';
        index_cache_fpath = fullfile(cache_dir,index_cache_fname);
        if exist(index_cache_fpath,'file') && ~index_cache_update
            fid = fopen(index_cache_fpath,'r');
            fnamelist = textscan(fid,'%s');
            fclose(fid);
            fnamelist = reshape(fnamelist{1},1,[]);
        else
            if exist(dir_local,'dir')
                filelist = dir(dir_local);
                fnamelist = {filelist.name};
                if ~exist(cache_dir,'dir'), mkdir(cache_dir); end
                fid = fopen(index_cache_fpath,'w');
                fprintf(fid,'%s\r\n',fnamelist{:});
                fclose(fid);
            else
                fnamelist = {};
            end
        end
    else
        filelist = dir(dir_local);
        fnamelist = {filelist.name};
    end
    [fnames_mtch,regexp_out] = mtch_ptrn_fnamelist(basenamePtr, ...
                    fnamelist,'exact',mtch_exact,'ext_ignore',ext_ignore);

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