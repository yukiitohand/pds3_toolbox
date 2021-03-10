function [imxy_direc_rov] = get_3d_pointing_from_CAHV_v2(im_size,cmmdl)
% [imxy_rov] = get_3d_pointing_from_CAHV(im_size,cmmdl)
% Get camera pointing vector for each camera image pixel (x_im, y_im)
% using camera CAHV model
% INPUTS
%   im_size: [L_im, S_im], size of the image
%   cmmdl: struct of CAHV camera model, fields are 'C','A','H','V'
% OUTPUTS
%   imxy_direc_rov: [L_im x S_im x 3] matrix. Directional vectors showing
%   pointing for the reference coordinate system. Each vector is
%   normalized.



L_im = im_size(1); S_im = im_size(2);

% get a [x_im,y_im] in the image coordinate
imx_im_1d = 0:(S_im-1);
imy_im_1d = reshape(0:(L_im-1),[],1);
[imx_im,imy_im] = meshgrid(imx_im_1d,imy_im_1d);

im_imxy_vec2d = [imx_im(:) imy_im(:)]';

pmc = cmmdl.get_p_minus_c_from_xy(im_imxy_vec2d);

imxy_direc_rov = reshape(pmc',[L_im,S_im,3]);

end