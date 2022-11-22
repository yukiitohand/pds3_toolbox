function [dirs,files] = naif_archive_downloader(subdir_local, varargin)
% [dirs,files] = pds_universal_downloader(subdir_local,varargin)
% Get the all the files that match "basenamePtrn" in the specified
% sub directory under pds-geoscience node.
%
% Inputs:
% With these inputs, files that match [BASENAMEPTRN] at 
%          [url_remote_root]/[subdir_remote] 
% are saved to
%          [localrootDir]/[url_local_root]/[subdir_local]
%
%  subdir_local    : local sub directory path
%  localrootDir    : root directory path at the local computer
%  url_local_root  : 
%  url_remote_root : 
%  func_getlnks    : function pointer that get links from the received html
%                   file.
%      
%   Optional Parameters
%      'SUBDIR_REMOTE   : (default) '' If empty, then SUBDIR_LOCAL is used.
%      'BASENAMEPTRN'   : Pattern for the regular expression for file.
%                         (default) '.*'
%      'DIRSKIP'        : if skip directories or walk into them
%                         (default) 1 (boolean)
%      'PROTOCOL'       : internet protocol for downloading
%                         (default) 'https'
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'HTMLFILE'           : path to the html file to be read
%                         (default) ''
%      'VERBOSE'        : boolean, whether or not to show the downloading
%                         operations.
%                         (default) true
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%   Outputs
%      dirs : cell array, list of dirs in the directory
%      files: cell array, list of files downloaded

global spicekrnl_env_vars
if isempty(spicekrnl_env_vars)
    error('Perform "spicekrnl_init" first.')
end
localrootDir    = spicekrnl_env_vars.local_SPICEkernel_archive_rootDir;
url_local_root  = spicekrnl_env_vars.url_local_root;
url_remote_root = spicekrnl_env_vars.url_remote_root;

[dirs,files] = pds_universal_downloader(subdir_local, ...
    localrootDir, url_local_root, url_remote_root, @get_links_remoteHTML_naif_archive, ...
    'protocol','https','CAPITALIZE_FILENAME', false,'VERBOSE',true,varargin{:});

end

