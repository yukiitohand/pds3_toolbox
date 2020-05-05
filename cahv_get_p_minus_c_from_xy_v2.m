function [p_minus_c] = cahv_get_p_minus_c_from_xy_v2(imxy_im_2d,cmmdl)
% [p_minus_c] = cahv_get_p_minus_c_from_xy(imxy_im_2d,cmmdl,varargin)
% Get camera pointing vector for 2d vectors in the image coordinate system
% using analytical solution
% INPUTS
%   imxy_im_2d: [2 x N] or [1 x 2]
%     A matrix whose columns corresponds to two dimensional vectors [x y]
%     in the image coordinate. In case N=1, you can have a row vector
%     instead of a column vector.
%   cmmdl: obj of CAHV_MODEL
% OUTPUTS
%   p_minus_c: [3 x N] matrix or [1 x 3]. 
%   3D pointing vectors associated with the two dimensional vectors in the
%   image coordinate. Each vector is normalized. If the input imxy_im_2d is
%   a row vector [1 x 2], then the output is also a row vector.
%

if all(size(imxy_im_2d) == [1,2])
    imxy_im_2d = reshape(imxy_im_2d,[],1);
    imxy_im2d_is_rowvec = 1;
else
    imxy_im2d_is_rowvec = 0;
end
    
cmmdl_A = cmmdl.A';

if isempty(cmmdl.Hdash)
    cmmdl.get_image_plane_unit_vectors();
end 

cff_A = cmmdl.hs*cmmdl.vs;
cff_Hd = (imxy_im_2d(1,:)-cmmdl.hc)*cmmdl.vs;
cff_Vd = (imxy_im_2d(2,:)-cmmdl.vc)*cmmdl.hs;
Hdash = cmmdl.Hdash';
Vdash = cmmdl.Vdash';

% theoretical solution
p_minus_c = cff_A.*cmmdl_A + cff_Hd.*Hdash + cff_Vd.*Vdash;

% normalization
nrm_factor = sqrt( cff_A.^2 + cff_Hd.^2 + cff_Vd.^2 );
p_minus_c = p_minus_c ./ nrm_factor; 

% check the direction
right_dir = sign(cmmdl.A*p_minus_c);
p_minus_c = p_minus_c .* right_dir;

if imxy_im2d_is_rowvec
    p_minus_c = reshape(p_minus_c,1,[]);
end


end