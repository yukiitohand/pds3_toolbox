function [cahv_mdl_t] = transform_cahv_mdl(cahv_mdl,C,rot_mat,varargin)
% [cahv_mdl_t] = transform_cahv_mdl(cahv_mdl,C,rot_mat)
%  Transform CAHV model with a new camera center and rotation matrix
% 

if isempty(C)
    Cnew = cahv_mdl.C;
else
    Cnew = C;
end
Anew = cahv_mdl.A * rot_mat';
Hdash_new = cahv_mdl.Hdash * rot_mat';
Vdash_new = cahv_mdl.Vdash * rot_mat';

Hnew = cahv_mdl.hs * Hdash_new + cahv_mdl.hc * Anew;
Vnew = cahv_mdl.vs * Vdash_new + cahv_mdl.vc * Anew;

cahv_mdl_t = CAHV_MODEL('C',Cnew,'A',Anew,'H',Hnew,'V',Vnew);
cahv_mdl_t.hs = cahv_mdl.hs;
cahv_mdl_t.vs = cahv_mdl.vs;
cahv_mdl_t.hc = cahv_mdl.hc;
cahv_mdl_t.vc = cahv_mdl.vc;
cahv_mdl_t.Hdash = Hdash_new;
cahv_mdl_t.Vdash = Vdash_new;


end