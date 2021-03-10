function [dirs,files] = pds_geosciences_node_universal_downloader(subdir_local,varargin)
% [dirs,files] = pds_geosciences_node_universal_downloader(subdir_local,varargin)
% Get the all the files that match "basenamePtrn" in the specified
% sub directory under pds-geoscience node.
%
% Inputs:
%  subdir_local:
%      
%   Optional Parameters
%      'SUBDIR_REMOTE   : (default) ''If empty, then 'SUBDIR_LOCAL is used.
%      'BASENAMEPTRN'   : Pattern for the regular expression for file.
%                         (default) '.*'
%      'DIRSKIP'        : if skip directories or walk into them
%                         (default) 1 (boolean)
%      'PROTOCOL'       : internet protocol for downloading
%                         (default) 'http' (only this is supported)
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'HTMLFILE'           : path to the html file to be read
%                         (default) ''
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%   Outputs
%      dirs: cell array, list of dirs in the directory
%      files: cell array, list of files downloaded
% 

global pds_geosciences_node_env_vars
localrootDir = pds_geosciences_node_env_vars.local_pds_geosciences_node_rootDir;
url_local_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;
url_remote_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;


basenamePtrn = '.*';
protocol = 'http';
subdir_remote = '';
overwrite = 0;
dirskip = 1;
dwld = 0;
html_file = '';
outfile = '';

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
            otherwise
                % Something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

if dwld==0
    fprintf('Nothing is performed with Download=%d\n',dwld);
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
    if verLessThan('matlab','8.4')
        [html,status] = urlread([protocol '://' url_remote]);
        if ~status
    %         fprintf('URL: "%s" is invalid.\n',url);
    %         fprintf('crism_pds_archiveURL: "%s"\n',crism_pds_archiveURL); 
    %         fprintf('subdir: "%s"\n',subdir);
    %         fprintf('Please input a valid combination of "crism_pds_archiveURL" and "subdir".\n');
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
    [lnks] = get_links_remoteHTML_pds_geosciences_node(html);


    match_flg = 0;
    for i=1:length(lnks)
        if any(strcmpi(lnks(i).type,{'PARENTDIR','To Parent Directory'}))
            % skip if it is 'PARENTDIR'
        elseif strcmpi(lnks(i).type,'DIR')
            dirs = [dirs {lnks(i).hyperlink}];
            if dirskip
               % skip
            else
                % recursively access the directory
                fprintf('Going to %s\n',joinPath(subdir_local,lnks(i).hyperlink));
                [dirs_ch,files_ch] = pds_geoscience_node_universal_downloader(...
                    joinPath(subdir_local,upper(lnks(i).hyperlink)),...
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
                
                localTarget =joinPath(localTargetDir,upper(lnks(i).hyperlink));
                if dwld==2
                    if exist(localTarget,'file') && ~overwrite
                        fprintf('Exist: %s\n',localTarget);
                        fprintf('Skip downloading\n');
                    else
                        flg_d=1;
                        max_trial = 2;
                        mt = 1;
                        while flg_d
                            try
                                if exist(localTarget,'file') && overwrite
                                    fprintf('Exist: %s\n',localTarget);
                                    fprintf('Overwriting..');
                                end
                                fprintf(['Copy\t' remoteFile '\n\t-->\t' localTarget '\n']);
                                if verLessThan('matlab','8.4')
                                    urlwrite(remoteFile,localTarget);
                                else
                                    options = weboptions('ContentType','raw','Timeout',600);
                                    websave_robust(localTarget,remoteFile,options);
                                end
                                fprintf('......Done!\n');
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
                elseif dwld==0
                    fprintf('Nothing happens with dwld=0\n');
                else
                    error('dwld=%d is not defined\n',dwld);
                end
                files = [files {upper(lnks(i).hyperlink)}];
            end

        end   
    end
    if match_flg==0
        fprintf('No file matches %s in %s.\n',basenamePtrn,subdir_remote);
        
    end
end

if ~isempty(outfile)
    fclose(fp);
end

end
