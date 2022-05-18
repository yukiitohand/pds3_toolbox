function [] = pds3_startup_addpath()
%% Automatically find the path to toolboxes
fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);
path_ptrn = '(?<parent_dirpath>.*)/(?<toolbox_dirname>[^/]+[/]{0,1})';
mtch = regexpi(dirpath_self,path_ptrn,'names');
toolbox_root_dir = mtch.parent_dirpath;
pds3_toolbox_dirname  = mtch.toolbox_dirname;

%% find dependent toolboxes
dList = dir(toolbox_root_dir);
error_if_not_unique = true;
pathCell = strsplit(path, pathsep);

% base toolbox
[base_toolbox_dir,base_toolbox_dirname] = get_toolbox_dirname(dList, ...
    'base',error_if_not_unique);
if ~check_path_exist(base_toolbox_dir, pathCell)
    addpath(base_toolbox_dir);
end

% envi toolbox
[envi_toolbox_dir,envi_toolbox_dirname] = get_toolbox_dirname(dList, ...
    'envi',error_if_not_unique);
if ~check_path_exist(envi_toolbox_dir, pathCell)
    run(joinPath(envi_toolbox_dir,'envi_startup_addpath'));
end

%% pds3_toolbox
pds3_toolbox_dir = joinPath(toolbox_root_dir, pds3_toolbox_dirname);
if ~check_path_exist(pds3_toolbox_dir, pathCell)
    addpath( ...
        pds3_toolbox_dir                                , ...
        joinPath(pds3_toolbox_dir,'generic/')           , ...
        joinPath(pds3_toolbox_dir,'generic/connect/')   , ...
        joinPath(pds3_toolbox_dir,'generic/readwrite/') , ...
        joinPath(pds3_toolbox_dir,'generic/setting/')   , ...
        joinPath(pds3_toolbox_dir,'generic/util/')      , ...
        joinPath(pds3_toolbox_dir,'cahvor/') , ...
        joinPath(pds3_toolbox_dir,'hirise/') , ...
        joinPath(pds3_toolbox_dir,'mola/')   , ...
        joinPath(pds3_toolbox_dir,'naif/')   , ...
        joinPath(pds3_toolbox_dir,'naif/base/')   , ...
        joinPath(pds3_toolbox_dir,'naif/base/connect/')   , ...
        joinPath(pds3_toolbox_dir,'naif/base/setting/')   , ...
        joinPath(pds3_toolbox_dir,'naif/spice_plus/')     , ...
        joinPath(pds3_toolbox_dir,'naif/util/')             ...
    );

    cmp_arch = computer('arch');
    switch cmp_arch
        case 'maci64'
            % For Mac computers
            pds3_mex_build_path = joinPath(pds3_toolbox_dir,'mex_build/maci64/');
        case 'glnxa64'
            % For Linux/Unix computers with x86-64 architechture.
            pds3_mex_build_path = joinPath(pds3_toolbox_dir,'mex_build/glnxa64/');
        case 'win64'
            pds3_mex_build_path = joinPath(pds3_toolbox_dir,'mex_build/win64/');
        otherwise
            error('%s is not supported',cmp_arch);
    end

    if exist(pds3_mex_build_path,'dir')
        addpath(pds3_mex_build_path);
    else
        addpath(pds3_mex_build_path);
        fprintf('Run pds3_script_compile_all.m to compile C/MEX sources.\n');
    end
end

end

%%
function [onPath] = check_path_exist(dirpath, pathCell)
    % pathCell = strsplit(path, pathsep, 'split');
    if ispc || ismac 
      onPath = any(strcmpi(dirpath, pathCell));
    else
      onPath = any(strcmp(dirpath, pathCell));
    end
end

function [toolbox_dirpath,toolbox_dirname] = get_toolbox_dirname(dList,toolbox_dirname_wover,error_if_not_unique)
    dirname_ptrn = sprintf('(?<toolbox_dirname>%s(-[\\d\\.]+){0,1}[/]{0,1})',toolbox_dirname_wover);
    mtch_toolbox_dirname = regexpi({dList.name},dirname_ptrn,'names');
    mtchidx = find(not(cellfun('isempty',mtch_toolbox_dirname)));
    toolbox_root_dir = dList(1).folder;
    if length(mtchidx)==1
        toolbox_dirname = mtch_toolbox_dirname{mtchidx}.toolbox_dirname;
        toolbox_dirpath = [toolbox_root_dir, '/', toolbox_dirname];
    elseif isempty(mtchidx)
        toolbox_dirname = [];
        toolbox_dirpath = [];
        if error_if_not_unique
            
            error(['Cannot find %s toolbox in\n %s', ...
                   'Download from\n', ...
                   '   https://github.com/yukiitohand/%s/', ...
                  ], ...
                toolbox_dirname_wover,toolbox_root_dir,toolbox_dirname_wover);
        end
    else % length(mtchidx)>1
        toolbox_dirname = {cat(2,mtch_toolbox_dirname{mtchidx}).toolbox_dirname};
        toolbox_dirpath = cellfun(@(x) strjoin({toolbox_root_dir,x},'/'), toolbox_dirname, ...
            'UniformOutput',false);
        if error_if_not_unique
            toolbox_root_dir = dList(1).folder;
            error('Multiple %s toolboxes %s are detected in\n %s', ...
            toolbox_dirname_wover,strjoin(toolbox_dirname,','), toolbox_root_dir);
        end
        
    end
end