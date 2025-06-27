function [dirs,files] = pds_imaging_node_downloader(subdir_local,varargin)
% [dirs,files] = pds_imaging_node_downloader(subdir_local,varargin)
% Get the all the files that match "basenamePtrn" in the specified
% sub directory under pds-imaging node.
%
% Inputs:
%  subdir_local: subdirectory path
%      
%   Optional Parameters
%      'SUBDIR_REMOTE   : (default) '' If empty, then SUBDIR_LOCAL is used.
%      'BASENAMEPTRN'   : Pattern for the regular expression for file.
%                         (default) '.*'
%      'EXTENSION','EXT': Files with the extention will be downloaded. If
%                         it is empty, then files with any extension will
%                         be downloaded.
%                         (default) ''
%      'DIRSKIP'        : if skip directories or walk into them
%                         (default) 1 (boolean)
%      'PROTOCOL'       : internet protocol for downloading
%                         (default) 'http'
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'HTMLFILE'       : path to the html file to be read
%                         (default) ''
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%   Outputs
%      dirs: cell array, list of dirs in the directory
%      files: cell array, list of files downloaded
% 

global pds_imaging_node_env_vars
localrootDir = pds_imaging_node_env_vars.local_pds_imaging_node_rootDir;
url_local_root = pds_imaging_node_env_vars.pds_imaging_node_root_URL;
url_remote_root = pds_imaging_node_env_vars.pds_imaging_node_root_URL;

basenamePtrn  = '.*';
ext           = '';
subdir_remote = '';
overwrite     = 0;
dirskip       = 1;
dwld          = 0;
html_file     = '';
protocol      = 'https';
noindex = false;
index_cache_update = false;
verbose = true;
is_chmod777 = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BASENAMEPTRN'
                basenamePtrn = varargin{i+1};
            case 'SUBDIR_REMOTE'
                subdir_remote = varargin{i+1};
            case 'PROTOCOL'
                protocol = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'DIRSKIP'
                dirskip = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'HTML_FILE'
                html_file = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'NOINDEX'
                noindex = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'CHMOD777'
                is_chmod777 = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end
% 

% url_remote_root = crism_swap_to_remote_path(url_remote_root);
index_cache_fname = 'index.html';
[dirs,files] = pds_universal_downloader(subdir_local, ...
    localrootDir, url_local_root, url_remote_root, @get_links_remoteHTML_pds_imaging_node, ...
    'BASENAMEPTRN',basenamePtrn,'SUBDIR_REMOTE',subdir_remote, ...
    'CAPITALIZE_FILENAME', false,'VERBOSE',verbose,'EXT',ext,'DIRSKIP',dirskip, ...
    'protocol',protocol,'overwrite',overwrite,'dwld',dwld, ...
    'NOINDEX', noindex, ...
    'HTML_FILE', html_file, 'CHMOD777',is_chmod777, ...
    'INDEX_CACHE_UPDATE',index_cache_update,'INDEX_CACHE_FILENAME',index_cache_fname);



end
