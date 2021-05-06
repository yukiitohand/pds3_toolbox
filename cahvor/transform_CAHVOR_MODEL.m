function [cmmdl_new] = transform_CAHVOR_MODEL(cmmdl,rot_mat,varargin)
% [cmmdl_new] = transform_CAHVOR_MODEL(cmmdl,rot_mat,varargin)
%  Convert CAHV_MODEL with a rotation matrix and the translation vector.
% INPUTS
%   cmmdl: CAHV_MODEL/CAHVOR_MODEL class obj.
%   rot_mat: 3 x 3 rotation matrix
% OUTPUTS
%   cmmdl_new: CAHV_MODEL/CAHVOR_MODEL class obj.
%       
% OPTIONAL Parameters
%   "TRANSLATION_ORDER": {'Before', 'After'}
%     whether or not translation is based on the corrected coordinate 
%     system or not. Valid for the two rotation axes - 'CAMERA' and 'ROVER'.
%     (default) 'Before'
%     'Before' - translation is performed based on the original coordinate
%                system.
%     'After'  - translation is performed based on the corrected coordinate
%                system.
%   "TRANSLATION_VECTOR": 1 x 3 size vector
%     translation parameter for each direction of the coordinate system
%     specified with 'TRANSLATION_AXIS'
%     (default) [0 0 0]
%
% Tips
%  The input camera model has C(center), A(axis) H(horizontal),
%  V(vertical), (O(Optical), R(radial)) parameters. The output camera model
%  rotates this model by rot_mat. Namely, if these vectors are column ones,
%  it performs:
%           rot_mat * C(:), rot_mat * A(:), rot_mat * H(:), rot_mat * V(:)
%  Note that applying rotation matrix to H and V is equivalent to rotating
%  the horizontal and vertical basis vectors (Hd and Vd) of the camera 
%  model in the original coordinate system. Translation can be done either
%  before or after the rotation. If 'before' is chosen, the new camera
%  center is rot_mat * (C(:) + tlvec(:)). If 'after is chosen, it is 
%  rot_mat * C(:) + tlvec(:).

tlorder = 'BEFORE';
tlvec   = [0 0 0];
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'TRANSLATION_ORDER'
                tlorder = upper(varargin{i+1});
            case 'TRANSLATION_VECTOR'
                tlvec = varargin{i+1};
                if iscolumn(tlvec)
                    tlvec = tlvec';
                end
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end


cmmdl_A_new = cmmdl.A * rot_mat';
cmmdl_H_new = cmmdl.H * rot_mat';
cmmdl_V_new = cmmdl.V * rot_mat';

switch upper(tlorder)
    case 'AFTER'
        cmmdl_C_new = cmmdl.C * rot_mat' + tlvec;
    case 'BEFORE'
        cmmdl_C_new = (cmmdl.C + tlvec) * rot_mat';
end

switch class(cmmdl)
    case 'CAHV_MODEL'
        cmmdl_new = CAHV_MODEL('C',cmmdl_C_new,'A',cmmdl_A_new,...
            'H',cmmdl_H_new,'V',cmmdl_V_new);
    case 'CAHVOR_MODEL'
        cmmdl_O_new = cmmdl.O * rot_mat';
        cmmdl_new = CAHVOR_MODEL('C',cmmdl_C_new,'A',cmmdl_A_new,...
            'H',cmmdl_H_new,'V',cmmdl_V_new,'O',cmmdl_O_new,'R',cmmdl.R);
    otherwise
        error('Undefined input cmmdl %s.',class(cmmdl));
end

end