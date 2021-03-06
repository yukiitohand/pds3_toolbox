function [cmmdl_geo] = transform_CAHVOR_MODEL_wROVER_NAV(cmmdl,rover_nav)


cmmdl_C_rov0 = cmmdl.C * rover_nav.rot_mat';
cmmdl_A_rov0 = cmmdl.A * rover_nav.rot_mat';
cmmdl_H_rov0 = cmmdl.H * rover_nav.rot_mat';
cmmdl_V_rov0 = cmmdl.V * rover_nav.rot_mat';

cmmdl_C_geo = cmmdl_C_rov0 + [rover_nav.NORTHING,rover_nav.EASTING,-rover_nav.ELEVATION];

switch class(cmmdl)
    case 'CAHV_MODEL'
        cmmdl_geo = CAHV_MODEL('C',cmmdl_C_geo,'A',cmmdl_A_rov0,...
            'H',cmmdl_H_rov0,'V',cmmdl_V_rov0);
    case 'CAHVOR_MODEL'
        cmmdl_O_rov0 = cmmdl.O * rover_nav.rot_mat';
        cmmdl_geo = CAHVOR_MODEL('C',cmmdl_C_geo,'A',cmmdl_A_rov0,...
            'H',cmmdl_H_rov0,'V',cmmdl_V_rov0,'O',cmmdl_O_rov0,'R',cmmdl.R);
    otherwise
        error('Undefined input cmmdl %s.',class(cmmdl));
end

end