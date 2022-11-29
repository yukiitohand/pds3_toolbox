function spicekrnl_init(varargin)
% Load environmental variables for using SPICE kernel
% The variables stored in a global variable crism_env_vars
% USAGE
% >> spicekrnl_init
% >> spicekrnl_init spicekrnl.json
%
% 
    global spicekrnl_env_vars

    if isempty(varargin)
        spickrnl_env_json_fname = 'spicekrnl_env.json';
    elseif length(varargin)==1
        spickrnl_env_json_fname = varargin{1};
    else
        error('Too many input parameters.');
    end

    str = fileread(spickrnl_env_json_fname);
    spicekrnl_env_vars = jsondecode(str);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Backward compatibility
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % no_remote is determined based on the presence of the field 
    % 'remote_fldsys', if it is not defined in the json file.
    if ~isfield(spicekrnl_env_vars,'no_remote')
        spicekrnl_env_vars.no_remote = false;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [yesno,doyoucreate] = check_mkdir(spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
    switch lower(doyoucreate)
        case 'yes'
            [status] = mkdir(spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
            if status
                fprintf('%s is created...\n',spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
                % [yesno777] = doyouwantto('change the permission to 777', '');
                % if yesno777
                %     chmod777(spicekrnl_env_vars.localCRISM_PDSrootDir,1);
                % end
            else
                error('Failed to create %s', spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
            end
        case 'no'
            if strcmpi(yesno,'no')
                fprintf('No local database will be created. ');
                fprintf('Functionality of crism_toolbox may be limited.\n');
            end
        otherwise
            error('"doyoucreate" should be either of "yes" or "no".');
            
    end
    
    spicekrnl_env_vars.url_local_root = spicekrnl_env_vars.([spicekrnl_env_vars.local_fldsys '_URL']);
    spicekrnl_env_vars.url_local_root = fullfile(spicekrnl_env_vars.url_local_root);

    if ~spicekrnl_env_vars.no_remote
        % remote_protocol is set to 'http' if not defined in the json file.
        if ~isfield(spicekrnl_env_vars,'remote_protocol')
            spicekrnl_env_vars.remote_protocol = 'http';
        end
        spicekrnl_env_vars.url_remote_root = spicekrnl_env_vars.([spicekrnl_env_vars.fldsys '_URL']);
        spicekrnl_env_vars.url_remote_root = crism_swap_to_remote_path(spicekrnl_env_vars.url_remote_root);
    end

end

function [yesno,doyoucreate] = check_mkdir(dirpath)
    exist_flg = exist(dirpath,'dir');
    if exist_flg
        yesno = 'yes'; doyoucreate = 'no';
    else
        flg = 1;
        while flg
            prompt = sprintf('%s does not exist. Do you want to create?(y/n)',dirpath);
            ow = input(prompt,'s');
            if any(strcmpi(ow,{'y','n'}))
                flg=0;
            else
                fprintf('Input %s is not valid.\n',ow);
            end
        end
        if strcmpi(ow,'n')
            yesno = 'yes';  doyoucreate = 'no';
        elseif strcmpi(ow,'y')
            yesno = 'no';  doyoucreate = 'yes';
        end
    end
end

    