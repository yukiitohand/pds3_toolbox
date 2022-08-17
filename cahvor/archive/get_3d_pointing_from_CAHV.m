function [imxy_direc_rov] = get_3d_pointing_from_CAHV(im_size,cmmdl,varargin)
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

is_gpu = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'GPU'
                is_gpu = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

L_im = im_size(1); S_im = im_size(2);
cmmdl_C = cmmdl.C;
cmmdl_A = cmmdl.A;
cmmdl_H = cmmdl.H;
cmmdl_V = cmmdl.V;

% get a [x_im,y_im] in the image coordinate
imx_im_1d = 1:S_im;
imy_im_1d = reshape(1:L_im,[],1);
[imx_im,imy_im] = meshgrid(imx_im_1d,imy_im_1d);

imxy_im_2d = permute(reshape(cat(2,imx_im,imy_im),[L_im*S_im,2]),[2,3,1]);

% compute pointing of each pixel in the reference coordinate.
% this is done by matrix inversion.
HmXAt = cmmdl_H - cmmdl_A .* imxy_im_2d(1,:,:);
VmYAt = cmmdl_V - cmmdl_A .* imxy_im_2d(2,:,:);
M = cat(1,HmXAt,VmYAt,repmat([1 1 1],1,1,size(imxy_im_2d,3)));
h = repmat(reshape([0 0 1],[],1),[1,1,L_im*S_im]);
% h = cat(1,mmx('mult',HmXAt,cmmdl_C'),mmx('mult',VmYAt,cmmdl_C'),repmat([1],1,1,size(imxy_im_2d,3)));
% p_xy = pagefun(@ldivide,M,h);
if is_gpu
    M = gpuArray(M); h = gpuArray(h);
    imxy_direc_rov = permute(pagefun(@mldivide,M,h),[1,3,2]);
    [M,h,imxy_direc_rov] = gather(M,h,imxy_direc_rov);
else
    imxy_direc_rov = permute(mmx('backslash',M,h),[1,3,2]);
end

% normalization
imxy_direc_rov = normalizevec(imxy_direc_rov,1,'normtype',2);
% check the direction by taking innerdots with camera axis.
is_lookback = (cmmdl_A * imxy_direc_rov)<0;
imxy_direc_rov(:,is_lookback) = -imxy_direc_rov(:,is_lookback);

imxy_direc_rov = permute(reshape(imxy_direc_rov,3,L_im,S_im),[2,3,1]);

end