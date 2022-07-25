function [] = pds3_script_compile_all()
% pds3_script_compile_all.m
% Script for compiling all the necessary C/MEX codes
%
% Automatically find the path to msl_toolbox and pds3_toolbox
% If you want to use the separate installation of pds3_toolbox, manually
% edit "pds3_toolbox_path"

fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);
[dirpath_toolbox,pds3_toolbox_dirname] = fileparts(dirpath_self);

pds3_toolbox_path  = fullfile(dirpath_toolbox, pds3_toolbox_dirname);
spice_toolbox_path = fullfile(dirpath_toolbox, 'spice');


%% Prior checking if necessary files are accessible.
if ~exist(pds3_toolbox_path,'dir')
    error('pds3_toolbox does not exist. Get at github.com/yukiitohand/pds3_toolbox/');
end

if ~exist(spice_toolbox_path,'dir')
    error(sprintf(['SPICE/MICE does not seem to be detected. Download'     '\n'...
           ' mice.tar.Z and importMice.csh' '\n'...
           ' from'                          '\n'...
           '   https://naif.jpl.nasa.gov/naif/toolkit_MATLAB.html' '\n'...
           sprintf(' into %s',spice_toolbox_path)                  '\n'...
           ' and run' '\n'...
           ' /bin/csh -f importMice.csh' '\n'...
          ]));
end

% Sorry, these functions are currently not supported for MATLAB 9.3 or
% earlier. These requires another 
if verLessThan('matlab','9.4')
    error('You need MATLAB version 9.4 or newer');
end

%% Set source code paths and the output directory path.
pds3_toolbox_mex_include_path = fullfile(pds3_toolbox_path, 'mex_include');
SpiceUsr_include_path = fullfile(spice_toolbox_path, 'mice','include');
spice_lib_path = fullfile(spice_toolbox_path,'mice','lib');

% 
source_filepaths = { ...
    fullfile(pds3_toolbox_path,'cahvor','cahvor_get_lambda_bisection.c')  , ...
    fullfile(pds3_toolbox_path,'mola','mola_megdr_average_mex.c')         , ...
    fullfile(pds3_toolbox_path,'mola','mola_megdr_upsample_double_mex.c') , ...
    fullfile(pds3_toolbox_path,'mola','mola_megdr_upsample_int16_mex.c')    ...
};

source_filepaths_spice = { ...
    fullfile(pds3_toolbox_path,'naif','spice_plus','cspice_surfpt_mex.c')        , ...
    fullfile(pds3_toolbox_path,'naif','spice_plus','cspice_surfpt_reclat_mex.c')   ...
};

switch computer
    case 'MACI64'
        out_dir = fullfile(pds3_toolbox_path,'mex_build','maci64');
    case 'GLNXA64'
        out_dir = fullfile(pds3_toolbox_path,'mex_build','glnxa64');
    case 'PCWIN64'
        out_dir = fullfile(pds3_toolbox_path,'mex_build','pcwin64');
    otherwise
        error('Undefined computer type %s.\n',computer);
end

if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

%% Compile files one by one
for i=1:length(source_filepaths)
    filepath = source_filepaths{i};
    fprintf('Compiling %s ...\n',filepath);
    mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
        '-outdir',out_dir);
end

% Some files (spice related) need to be compiled together with a static
% object file cspice.a and '-lm' option.
for i=1:length(source_filepaths_spice)
    filepath = source_filepaths_spice{i};
    fprintf('Compiling %s ...\n',filepath);
    mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
        ['-I' SpiceUsr_include_path], ...
        joinPath(spice_lib_path,'cspice.a'), ...
        '-lm', ...
        '-outdir',out_dir);
end

% If you manually compile mex codes, include the two directories 
%     pds3_toolbox_mex_include_path
% using -I option.
% Also do not forget to add '-R2018a'

end
