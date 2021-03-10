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
%      'DIRSKIP'        : if skip directories or walk into them
%                         (default) 1 (boolean)
%      'PROTOCOL'       : internet protocol for downloading
%                         (default) 'http'
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'HTMLFILE'           : path to the html file to be read
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


basenamePtrn = '.*';
protocol = 'http';
subdir_remote = '';
overwrite = 0;
dirskip = 1;
dwld = 0;
html_file = '';
outfile = '';
cap_filename = true;
index_cache_update = false;
vebose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BASENAMEPTRN'
                basenamePtrn = varargin{i+1};
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

no_local_directory = false;

url_local = joinPath(url_local_root,subdir_local);
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
        mkdir(localrootDir);
        fprintf('localrootdir "%s" is created.',localrootDir);
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
        if ~exist(localTargetDir,'dir'), mkdir(localTargetDir); end
        fid_index = fopen(html_cachefilepath,'w');
        fwrite(fid_index,html);
        fclose(fid_index);
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


    match_flg = 0;
    for i=1:length(lnks)
        if any(strcmpi(lnks(i).type,{'PARENTDIR','To Parent Directory'})) ...
                || strcmpi(lnks(i).text,'Parent Directory')
            % skip if it is 'PARENTDIR'
        elseif strcmpi(lnks(i).type,'DIR')
            dirs = [dirs {lnks(i).hyperlink}];
            if dirskip
               % skip
            else
                % recursively access the directory
                if verbose
                    fprintf('Going to %s\n',joinPath(subdir_local,lnks(i).hyperlink));
                end
                [dirs_ch,files_ch] = pds_geoscience_node_universal_downloader(...
                    joinPath(subdir_local,lnks(i).hyperlink),...
                    'SUBDIR_REMOTE',joinPath(subdir_remote,lnks(i).hyperlink),...
                    'Basenameptrn',basenamePtrn,'dirskip',dirskip,...
                    'protocol',protocol,'overwrite',overwrite,'dwld',dwld,...
                    'out_file',outfile);
            end
        else
            remoteFile = [protocol '://' joinPath(url_remote,lnks(i).hyperlink)];
            if ~isempty(regexpi(lnks(i).hyperlink,basenamePtrn,'ONCE'))
                match_flg = 1;
                
                if ~exist(localTargetDir,'dir') && ~no_local_directory
                    mkdir(localTargetDir);
                end
                if cap_filename
                    localTarget =joinPath(localTargetDir,upper(lnks(i).hyperlink));
                else
                    localTarget =joinPath(localTargetDir,lnks(i).hyperlink);
                end
                if dwld==2
                    if exist(localTarget,'file') && ~overwrite
                        if verbose
                            fprintf('Exist: %s\n',localTarget);
                            fprintf('Skip downloading\n');
                        end
                    else
                        flg_d=1;
                        max_trial = 2;
                        mt = 1;
                        while flg_d
                            try
                                if exist(localTarget,'file') && overwrite
                                    if verbose
                                        fprintf('Exist: %s\n',localTarget);
                                        fprintf('Overwriting..');
                                    end
                                end
                                if verbose
                                    fprintf(['Copy\t' remoteFile '\n\t-->\t' localTarget '\n']);
                                end
                                if verLessThan('matlab','8.4')
                                    urlwrite(remoteFile,localTarget);
                                else
                                    options = weboptions('ContentType','raw','Timeout',600);
                                    websave_robust(localTarget,remoteFile,options);
                                end
                                if verbose
                                    fprintf('......Done!\n');
                                end
                                flg_d=0;
                            catch
                                fprintf('Failed. Retrying...\n');
                                mt = mt + 1;
                                if mt > max_trial
                                    error('Download failed.');
                                end
                            end
                        end
                    end
                elseif dwld==1
                    if no_local_directory
                        if verbose
                            fprintf('%s\n',remoteFile);
                        end
                    else
                        if verbose
                            fprintf('%s,%s\n',remoteFile,localTarget);
                        end
                    end
                    if ~isempty(outfile)
                        if no_local_directory
                            if verbose
                                fprintf(fp,'%s\n',remoteFile);
                            end
                        else
                            if verbose
                                fprintf(fp,'%s,%s\n',remoteFile,localTarget);
                            end
                        end
                    end
                elseif dwld==0
                    if verbose
                        fprintf('Nothing happens with dwld=0\n');
                    end
                else
                    error('dwld=%d is not defined\n',dwld);
                end
                if cap_filename
                    files = [files {upper(lnks(i).hyperlink)}];
                else
                    files = [files {lnks(i).hyperlink}];
                end
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
