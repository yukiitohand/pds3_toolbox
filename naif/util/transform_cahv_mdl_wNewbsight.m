function [cahv_mdl_t] = transform_cahv_mdl_wNewbsight(cahv_mdl,bsight_new)


if iscolumn(bsight_new)
    bsight_new = bsight_new';
end

bsight_new = bsight_new / norm(bsight_new);
rot_axis = cross(cahv_mdl.A,bsight_new);
rot_axis = rot_axis / norm(rot_axis);
theta = acos(cahv_mdl.A * bsight_new');

Anew = bsight_new;
[Hdash_new,q] = rotation_using_quaternion(rot_axis,theta,cahv_mdl.Hdash);
Vdash_new = rotatepoint(q, cahv_mdl.Vdash);

Hnew = cahv_mdl.hs * Hdash_new + cahv_mdl.hc * Anew;
Vnew = cahv_mdl.vs * Vdash_new + cahv_mdl.vc * Anew;

cahv_mdl_t = CAHV_MODEL('C',cahv_mdl.C,'A',Anew,'H',Hnew,'V',Vnew);
cahv_mdl_t.hs = cahv_mdl.hs;
cahv_mdl_t.vs = cahv_mdl.vs;
cahv_mdl_t.hc = cahv_mdl.hc;
cahv_mdl_t.vc = cahv_mdl.vc;
cahv_mdl_t.Hdash = Hdash_new;
cahv_mdl_t.Vdash = Vdash_new;


end