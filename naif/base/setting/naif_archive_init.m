function naif_archive_init()
    global naif_archive_env_vars
    str = fileread('naif_archive.json');
    naif_archive_env_vars = jsondecode(str);
    
    check_mkdir(naif_archive_env_vars.local_naif_archive_rootDir);
    
end

function [] = check_mkdir(dirpath)
    exist_flg = exist(dirpath,'dir');
    if exist_flg
        %yesno = 1;
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
            fprintf('No local database will be created.\n');
        elseif strcmpi(ow,'y')
            fprintf('%s is created...\n',dirpath);
        end
    end
end