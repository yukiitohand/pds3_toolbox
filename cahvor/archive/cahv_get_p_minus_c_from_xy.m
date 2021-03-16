function [p_minus_c] = cahv_get_p_minus_c_from_xy(imxy_im_2d,cmmdl,varargin)
% [p_minus_c] = cahv_get_p_minus_c_from_xy(imxy_im_2d,cmmdl,varargin)
% Get camera pointing vector for 2d vectors in the image coordinate system
% using camera CAHV model inversion.
% INPUTS
%   imxy_im_2d: [2 x N] or [1 x 2]
%     A matrix whose columns corresponds to two dimensional vectors [x y]
%     in the image coordinate. In case N=1, you can have a row vector
%     instead of a column vector.
%   cmmdl: struct of CAHV camera model with fields 'C','A','H','V'
% OUTPUTS
%   imxy_PmC: [3 x N] matrix or [1 x 3]. 
%   3D pointing vectors associated with the two  dimensional vectors in the
%   image coordinate. Each vector is normalized. If the input imxy_im_2d is
%   a row vector [1 x 2], then the output is also a row vector.
%


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

if all(size(imxy_im_2d) == [1,2])
    imxy_im_2d = reshape(imxy_im_2d,[],1);
    imxy_im2d_is_rowvec = 1;
else
    imxy_im2d_is_rowvec = 0;
end
    
cmmdl_A = cmmdl.A;
cmmdl_H = cmmdl.H;
cmmdl_V = cmmdl.V;

N = size(imxy_im_2d,2);
imxy_im_2d = permute(imxy_im_2d,[1,3,2]);

% compute pointing of each pixel in the reference coordinate.
% this is done by matrix inversion.
HmXAt = cmmdl_H - cmmdl_A .* imxy_im_2d(1,:,:);
VmYAt = cmmdl_V - cmmdl_A .* imxy_im_2d(2,:,:);
M = cat(1,HmXAt,VmYAt,repmat([1 1 1],1,1,size(imxy_im_2d,3)));
h = repmat(reshape([0 0 1],[],1),[1,1,N]);
% h = cat(1,mmx('mult',HmXAt,cmmdl_C'),mmx('mult',VmYAt,cmmdl_C'),repmat([1],1,1,size(imxy_im_2d,3)));
% p_xy = pagefun(@ldivide,M,h);
if is_gpu
    M = gpuArray(M); h = gpuArray(h);
    p_minus_c = pagefun(@mldivide,M,h);
    [p_minus_c] = gather(p_minus_c);
else
    p_minus_c = mmx('backslash',M,h);
end

p_minus_c = permute(p_minus_c,[1,3,2]);
% normalization of the vectors
p_minus_c = normalizevec(p_minus_c,1,'normtype',2);

if imxy_im2d_is_rowvec
    p_minus_c = reshape(p_minus_c,1,[]);
end


end
