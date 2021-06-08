function [dirs,files] = pds_universal_downloader(subdir_local, ...
    localrootDir, url_local_root, url_remote_root, func_getlnks ,varargin)
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
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'VERBOSE'        : boolean, whether or not to show the downloading
%                         operations.
%                         (default) true
%      'CAPITALIZE_FILENAME' : whether or not capitalize the filenames or
%      not
%        (default) true
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%   Outputs
%      dirs: cell array, list of dirs in the directory
%      files: cell array, list of files downloaded
% 

% global pds_geosciences_node_env_vars
% localrootDir = pds_geosciences_node_env_vars.local_pds_geosciences_node_rootDir;
% url_local_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;
% url_remote_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;


basenamePtrn  = '.*';
ext           = '';
protocol      = 'http';
subdir_remote = '';
overwrite     = 0;
dirskip       = 1;
dwld          = 0;
html_file     = '';
outfile       = '';
cap_filename  = true;
index_cache_update = false;
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BASENAMEPTRN'
                basenamePtrn = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'SUBDIR_REMOTE'
                subdir_remote = varargin{i+1};
            case 'DIRSKIP'
                dirskip = varargin{i+1};
            case 'PROTOCOL'
                protocol = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'HTML_FILE'
                html_file = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'CAPITALIZE_FILENAME'
                cap_filename = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if dwld==0
    if verbose
        fprintf('Nothing is performed with Download=%d\n',dwld);
    end
    return;
end

if ~isempty(ext)
    if ischar(ext)
        if ~strcmp(ext(1),'.')
            ext = ['.' ext];
        end
    elseif iscell(ext)
        for i=1:length(ext)
            if ~strcmp(ext{i}(1),'.')
                ext{i} = ['.' ext];
            end
        end
        
    end
end

no_local_directory = false;

url_local      = joinPath(url_local_root,subdir_local);
localTargetDir = joinPath(localrootDir,url_local);
if isempty(subdir_remote)
   subdir_remote = subdir_local;
   url_remote = joinPath(url_remote_root, subdir_remote);
else
    if isHTTP_fullpath(subdir_remote)
        url_remote = getURLfrom_HTTP_fullpath(subdir_remote);
    else
        url_remote = joinPath(url_remote_root,subdir_remote);
    end
end

if ~exist(localrootDir,'dir')
    fprintf('localrootdir "%s" does not exist.',localrootDir);
    flg = 1;
    while flg
        prompt = sprintf('Do you want to create it? (y/n)');
        ow = input(prompt,'s');
        if any(strcmpi(ow,{'y','n'}))
            flg=0;
        else
            fprintf('Input %s is not valid.\n',ow);
        end
    end
    if strcmpi(ow,'n')
        flg2 = 1;
        while flg2
            prompt = sprintf('Do you want to continue(y/n)?');
            ow_2 = input(prompt,'s');
            if any(strcmpi(ow_2,{'y','n'}))
                flg2=0;
            else
                fprintf('Input %s is not valid.\n',ow);
            end
        end
        if strcmpi(ow_2,'y')
            if dwld==2
                error('No local database, so dwld=%d is not valid',dwld);
            elseif dwld == 1
                fprintf('only remote url will be printed.\n');
            end
            no_local_directory = true;
        elseif strcmpi(ow_2,'n')
            fprintf('Process aborted...\n');
            return;
        end
    elseif strcmpi(ow,'y')
        [status] = mkdir(localrootDir);
        if status
            fprintf('localrootdir "%s" is created.\n',localrootDir);
            if isunix
                system(['chmod -R 777 ' localrootDir]);
                if verbose, fprintf('localrootdir "%s": permission is set to 777.\n',localrootDir); end
            end
        else
            error('Failed to create %s',localrootDir);
        end
    end
end





dirs = []; files = [];

errflg=0;
if isempty(html_file)
    html_cachefilepath = joinPath(localTargetDir,'index.html');
    if ~index_cache_update && exist(html_cachefilepath,'file')
        html = fileread(html_cachefilepath);
    else
        if verLessThan('matlab','8.4')
            [html,status] = urlread([protocol '://' url_remote]);
            if ~status
                warning('URL: "%s" is invalid.\n',url_remote);
                errflg=1;
            end
        else
            ntrial = 1; % number of trial to retrieve the url
            while ~errflg
                try
                    options = weboptions('ContentType','text','Timeout',60);
                    http_url = [protocol '://' url_remote];
                    [html] = webread(http_url,options);
                    break;
                catch
                    if ntrial<3
                        ntrial=ntrial+1;
                    else
                        fprintf(2,'%s://%s does not exist.\n',protocol,url_remote);
                        errflg=1;
                    end
                end
            end
        end
        % create the target directory and set 777
        url_local_splt = split(url_local,'/');
        dcur = localrootDir;
        if ~exist(localTargetDir,'dir') % if the directory doesn't exist,
            for i=1:length(url_local_splt)
                dcur = joinPath(dcur,url_local_splt{i});
                if ~exist(dcur,'dir')
                    [status] = mkdir(dcur);
                    if status
                        if verbose, fprintf('"%s" is created.\n',dcur); end
                        chmod777(dcur,verbose);
                    else
                        error('Failed to create %s',dcur);
                    end
                end
            end
        end
        if exist(html_cachefilepath,'file')
            delete(html_cachefilepath);
        end
        fid_index = fopen(html_cachefilepath,'w');
        fwrite(fid_index,html);
        fclose(fid_index);
        chmod777(html_cachefilepath,verbose);
    end
else
    if exist(html_file,'file')
        html = fileread(html_file);
    else
        warning('html_file %s does not exist.',html_file);
        errflg = true;
    end
end
% 
if ~isempty(outfile)
    fp = fopen(outfile,'a');
end
if ~errflg
    
    % get all the links
    [lnks] = func_getlnks(html);
    % [lnks] = get_links_remoteHTML_pds_geosciences_node(html);
    fnamelist_local = dir(localTargetDir);
    fnamelist_local = {fnamelist_local(~[fnamelist_local.isdir]).name};
    match_flg = 0;
    for i=1:length(lnks)
        if any(strcmpi(lnks(i).type,{'PARENTDIR','To Parent Directory'})) ...
                || ( isfield(lnks(i),'text') && strcmpi(lnks(i).text,'Parent Directory') )
            % skip if it is 'PARENTDIR'
        elseif strcmpi(lnks(i).type,'DIR')
            dirname = lnks(i).hyperlink;
            dirs = [dirs {dirname}];
            if dirskip
               % skip
            else
                % recursively access the directory
                if verbose
                    fprintf('Going to %s\n',joinPath(subdir_local,dirname));
                end
                [dirs_ch,files_ch] = pds_universal_downloader(...
                    joinPath(subdir_local,lnks(i).hyperlink),...
                    'SUBDIR_REMOTE',joinPath(subdir_remote,dirname),...
                    'Basenameptrn',basenamePtrn,'EXT',ext,'dirskip',dirskip,...
                    'protocol',protocol,'overwrite',overwrite,'HTML_FILE',html_file,...
                    'dwld',dwld,'out_file',outfile,'CAPITALIZE_FILENAME',cap_filename, ...
                    'INDEX_CACHE_UPDATE',index_cache_update);
                for ii=1:length(dirs_ch)
                    dirs_ch{ii} = joinPath(dirname,dirs_ch{ii});
                end
                dirs = [dirs dirs_ch];
                for ii=1:length(files_ch)
                    files_ch{ii} = joinPath(dirname,files);
                end
                files = [files files_ch];
            end
        else
            filename = lnks(i).hyperlink;
            remoteFile = [protocol '://' joinPath(url_remote,filename)];
            if cap_filename
                filename_local = upper(filename);
            else
                filename_local = filename;
            end
            [~,~,ext_filename] = fileparts(filename);
            % Proceed if the filename matches the ptrn and extension
            % matches
            if ~isempty(regexpi(filename,basenamePtrn,'ONCE')) ...
                && ( isempty(ext) || ( ~isempty(ext) && any(strcmpi(ext_filename,ext)) ) )
                match_flg = 1;
                
                
                localTarget = joinPath(localTargetDir,filename_local);
                
                exist_idx = find(strcmpi(filename_local,fnamelist_local));
                exist_flg = ~isempty(exist_idx);
                
                switch dwld
                    case 2
                        if exist_flg && ~overwrite
                            % Skip downloading
                            if verbose
                                fprintf('Exist: %s\n',localTarget);
                                fprintf('Skip downloading\n');
                            end
                        else
                            if exist_flg && overwrite
                                if verbose
                                    fprintf('Exist: %s\n',localTarget);
                                    fprintf('Overwriting..');
                                    for ii=1:length(exist_idx)
                                        exist_idx_ii = exist_idx(ii);
                                        localExistFilePath = joinPath(localTargetDir,fnamelist_local{exist_idx_ii});
                                        fprintf('Deleting %s ...\n',localExistFilePath);
                                        delete(localExistFilePath);
                                    end
                                end
                            end
                            if verbose
                                fprintf(['Copy\t' remoteFile '\n\t-->\t' localTarget '\n']);
                            end
                            [err] = websavefile_multversion(remoteFile,localTarget);
                            if verbose
                                if err
                                    fprintf('......Download failed.\n');
                                else
                                    fprintf('......Done!\n');
                                    chmod777(localTarget,verbose);
                                end
                            end
                        end
                    case 1
                        if verbose
                            if no_local_directory
                                fprintf('%s\n',remoteFile);
                            else
                                fprintf('%s,%s\n',remoteFile,localTarget);
                            end
                            if ~isempty(outfile)
                                if no_local_directory
                                    fprintf(fp,'%s\n',remoteFile);
                                else
                                    fprintf(fp,'%s,%s\n',remoteFile,localTarget);
                                end
                            end
                        end
                    case 0
                        if verbose
                            fprintf('Nothing happens with dwld=0\n');
                        end
                    otherwise
                        error('dwld=%d is not defined\n',dwld);
                end
                
                files = [files {filename_local}];
            end

        end   
    end
    if match_flg==0
        if verbose
            fprintf('No file matches %s in %s.\n',basenamePtrn,subdir_remote);
        end
    end
end

if ~isempty(outfile)
    fclose(fp);
end

end

function [err] = websavefile_multversion(remoteFile,localTarget)
%[errcode] = websavefile_multversion(remoteFile,localTarget)
%   Download "remoteFile" to "localTarget"
%  INPUTS
%   remoteFile: address of the remote file with a protocol
%   localTarget: file path to which the file is saved.
%  OUTPUTS
%   err: 0 no error, 1: any error
flg=1; max_trial = 2; mt = 1;
while flg
    try
        if verLessThan('matlab','8.4')
            urlwrite(remoteFile,localTarget);
        else
            options = weboptions('ContentType','raw','Timeout',600);
            websave_robust(localTarget,remoteFile,options);
        end
        flg=0;
        err=0;
    catch
        fprintf('Failed. Retrying...\n');
        mt = mt + 1;
        if mt > max_trial
            flg=0;
            err=1;
        end
       
    end
end

end
