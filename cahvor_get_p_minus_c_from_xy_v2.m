function [p_minus_c] = cahvor_get_p_minus_c_from_xy_v2(imxy_im_2d,cmmdl)
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
% Update note
%   2020.09.11-YI: practical normalization is additionally performed.
%

if all(size(imxy_im_2d) == [1,2])
    imxy_im_2d = reshape(imxy_im_2d,[],1);
    imxy_im2d_is_rowvec = 1;
else
    imxy_im2d_is_rowvec = 0;
end

% get apparent direction
[pd_minus_c] = cahv_get_p_minus_c_from_xy_v2(imxy_im_2d,cmmdl);

%% converting from the apparent vector
pdmc_nrmd = pd_minus_c ./ (cmmdl.O*pd_minus_c);

klambda = pdmc_nrmd - cmmdl.O';

klambda_mag = sqrt(sum(klambda.^2,1));

lambda_mag = cahvor_get_lambda_bisection(klambda_mag,cmmdl.R);

p_minus_c = cmmdl.O' + (lambda_mag./klambda_mag) .* klambda;


%% Post processing
% the theoretical normalization factor sometimes causes small errors.
p_minus_c = p_minus_c ./ sqrt(sum(p_minus_c.^2,1));

% check the direction
right_dir = sign(cmmdl.A*p_minus_c);
p_minus_c = p_minus_c .* right_dir;

if imxy_im2d_is_rowvec
    p_minus_c = reshape(p_minus_c,1,[]);
end


end