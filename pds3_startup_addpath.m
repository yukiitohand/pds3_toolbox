function [] = pds3_startup_addpath()
%-------------------------------------------------------------------------%
% % Automatically find the path to toolboxes
fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);
toolbox_root_dir = dirpath_self(1:idx_sep-1);

%-------------------------------------------------------------------------%
% name of the directory of each toolbox
base_toolbox_dirname = 'base';
envi_toolbox_dirname = 'envi';

%-------------------------------------------------------------------------%
pathCell = strsplit(path, pathsep);

%% base toolbox
base_toolbox_dir = [toolbox_root_dir base_toolbox_dirname ];
% joinPath in base toolbox will be used in the following. "base" toolbox
% need to be loaded first. base/joinPath.m automatically determine the
% presence of trailing slash, so you do not need to worry it.
if exist(base_toolbox_dir,'dir')
    if ~check_path_exist(base_toolbox_dir, pathCell)
        addpath(base_toolbox_dir);
    end
else
    warning([ ...
        'base toolbox is not detected. Download from' '\n' ...
        '   https://github.com/yukiitohand/base/'
        ]);
end

%% envi toolbox
envi_toolbox_dir = joinPath(toolbox_root_dir, envi_toolbox_dirname);

if exist(envi_toolbox_dir,'dir')
    if ~check_path_exist(envi_toolbox_dir, pathCell)
        run(joinPath(envi_toolbox_dir,'envi_startup_path'));
    end
else
    warning([ ...
        'envi toolbox is not detected. Download from' '\n' ...
        '   https://github.com/yukiitohand/envi/'
        ]);
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