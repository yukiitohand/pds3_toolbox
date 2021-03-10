function [dirpath_local] = mola_megdr_get_dirpath_fromProp(propMEGDR)

global pds_geosciences_node_env_vars

if isempty(pds_geosciences_node_env_vars)
    error('Required env_vars is not found. Perform "pds_geoscience_node_setup" first.');
end
localrootDir = pds_geosciences_node_env_vars.local_pds_geosciences_node_rootDir;
url_local_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;
% url_remote_root = pds_geoscience_node_env_vars.pds_geoscience_node_root_URL;

subdir = 'mgs/mgs-m-mola-5-megdr-l3-v1/mgsl_300x/';

switch upper(propMEGDR.map_resol_id)
    case 'C'
        fldr = 'meg004';
    case 'E'
        fldr = 'meg016';
    case 'F'
        fldr = 'meg032';
    case 'G'
        fldr = 'meg064';
    case 'H'
        fldr = 'meg128';
    otherwise
        error('Undefined MAP_RESOL_ID: %s',propMEGDR.map_resol_id);
end

dirpath_local = joinPath(localrootDir,url_local_root,subdir,fldr);


end