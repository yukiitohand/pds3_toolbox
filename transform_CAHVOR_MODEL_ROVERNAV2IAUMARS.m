function [cmmdl_iaumars] = transform_CAHVOR_MODEL_ROVERNAV2IAUMARS( ...
    cmmdl, rover_nav_coord,varargin)
% [cmmdl_iaumars] = transform_CAHVOR_MODEL_ROVERNAV2IAUMARS( ...
%     cmmdl, rover_nav_coord,varargin)
%  Convert ROVER_NAV_FRAME based CAHV(OR) model to IAU_MARS - 
%  Planetocentric coordinate system.
% INPUTS
%  cmmdl: CAHV(OR)_MODEL class obj. its REFERENCE_COORD_SYSTEM property
%         needs to be 'ROVER_NAV_FRAME'.
%  rover_nav_coord: ROVER_NAV class obj. RADIUS property needs to be
%         non-empty.
% OUTPUTS
%  cmmdl_iaumars: CAHV(OR)_MODEL class obj. its REFERENCE_COORD_SYSTEM 
%         property is 'IAU_MARS'
% Optional Parameters
%  "MARS_SHAPE" : {'Sphere','Ellipsoid'}
%    shape of the mars. Affects the local tangential coordinate system
%    basis vectors.
%    (default) 'Sphere'
%
% Copyright(C) 2021 Yuki Itoh <yukiitohand@gmail.com>

mars_shp = 'Sphere';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MARS_SHAPE'
                mars_shp = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

switch upper(mars_shp)
    case 'SPHERE'
        phi = rover_nav_coord.PLANETOCENTRIC_LATITUDE;
    case {'ELLIPSOID'}
        [mars_radii] = mars_get_radii('Ellipsoid');
        re = mars_radii(1); rp = mars_radii(2);
        phi = atand((re/rp)^2*tand(rover_nav_coord.PLANETOCENTRIC_LATITUDE));
    otherwise
        error('Unrecognized MARS_SHAPE: %s', mars_shp);
end

if ~strcmpi(cmmdl.REFERENCE_COORD_SYSTEM,'ROVER_NAV_FRAME')
    error('INPUT cmmdl is not based on ROVER_NAV_FRAME');
end

cmmdl_rov0 = transform_CAHVOR_MODEL(cmmdl,rover_nav_coord.rot_mat);
% convert cahv_model in rover_nav reference to iau mars 
% planetocentric rectangular coordinate
cos_theta = cosd(rover_nav_coord.LONGITUDE);
sin_theta = sind(rover_nav_coord.LONGITUDE);
cos_phi   = cosd(phi);
sin_phi   = sind(phi);
radius_vec = [ cos_phi*cos_theta  cos_phi*sin_theta sin_phi];
north_vec  = [-sin_phi*cos_theta -sin_phi*sin_theta cos_phi];
east_vec   = [-sin_theta cos_theta 0];
rot_mat_iau_mars = [north_vec' east_vec' -radius_vec'];
%
if isempty(rover_nav_coord.RADIUS)
    error('Non empty RADIUS prpperty for rover_nav_coord is required.');
end
if ~isempty(rover_nav_coord.RADIUS_OFFSET)
    radius = rover_nav_coord.RADIUS + rover_nav_coord.RADIUS_OFFSET;
else
    radius = rover_nav_coord.RADIUS;
end
rover_nav_iau_mars = radius * radius_vec;
cmmdl_iaumars = transform_CAHVOR_MODEL(cmmdl_rov0,rot_mat_iau_mars, ...
    'TRANSLATION_VECTOR',rover_nav_iau_mars,'TRANSLATION_ORDER','after');
cmmdl_iaumars.REFERENCE_COORD_SYSTEM = 'IAU_MARS';

end