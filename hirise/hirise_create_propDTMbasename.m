function [prop] = hirise_create_propDTMbasename( varargin )
% [prop] = hirise_create_propDTMbasename( varargin )
%  return struct of HiRISE DTM data
% OUTPUT
%  prop: struct storing properties
%   data_class              : 'DT';
%   data_type               : '(?<data_type>[ER]{1})';
%   projection              : '(?<projection>[EP]{1})';
%   grid_spacing            : '(?<grid_spacing>[A-E]{1})';
%   orbit_num_target_code_1 : '(?<orbit_num_target_code_1>[\d]{6}_[\d]{4})';
%   orbit_num_target_code_2 : '(?<orbit_num_target_code_2>[\d]{6}_[\d]{4})';
%   institution_id          : '(?<institution_id>[ACJNOPUZ]{1})';
%   version                 : '(?<version>[\d]{2})';
% OPTIONAL Parameters
%   'DATA_TYPE','PROJECTION','GRID_SPACING','ORBIT_NUM_TARGET_CODE_1'
%   'ORBIT_NUM_TARGET_CODE_2','INSTITUTION_ID','VERSION'

% PRODUCT_ID = aabcd_xxxxxx_xxxx_yyyyyy_yyyy_Vnn
% where
% aa = DT, indicating it's a DTM product
% b = type of data {'E','R'}
%    E = areoid elevations
%    R = radii
% c = projection (others are possible but these are the important ones)
%    E = Equirectangular
%    P = Polar Stereographic
% d = grid spacing
%    A = 0.25 m
%    B = 0.5 m
%    C = 1.0 m
%    D = 2.0 m
%    E = 4.0 m
%    etc.
% xxxxxx_xxxx = orbit number and target code from SOURCE_PRODUCT_ID[1]
% yyyyyy_yyyy = orbit number and target code from SOURCE_PRODUCT_ID[2]
% V = letter indicating producing institution
%    U = USGS
%    A = University of Arizona
%    C = CalTech
%    N = NASA Ames
%    J = JPL
%    O = Ohio State
%    P = Planetary Science Institute
%    Z = Other
% nn = 2 digit version number

data_class = '(?<data_class>DT)';
data_type    = '(?<data_type>[ER]{1})';
projection   = '(?<projection>[EP]{1})';
grid_spacing = '(?<grid_spacing>[A-E]{1})';
orbit_num_target_code_1 = '(?<orbit_num_target_code_1>[\d]{6}_[\d]{4})';
orbit_num_target_code_2 = '(?<orbit_num_target_code_2>[\d]{6}_[\d]{4})';
institution_id = '(?<institution_id>[ACJNOPUZ]{1})';
vr = '(?<version>[\d]{2})';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'DATA_TYPE'
                data_type = varargin{i+1};
            case 'PROJECTION'
                projection = varargin{i+1};
            case 'GRID_SPACING'
                grid_spacing = varargin{i+1};
            case 'ORBIT_NUM_TARGET_CODE_1'
                orbit_num_target_code_1 = varargin{i+1};
            case 'ORBIT_NUM_TARGET_CODE_2'
                orbit_num_target_code_2 = varargin{i+1};
            case 'INSTITUTION_ID'
                institution_id = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end

prop = [];
prop.data_class = data_class;
prop.data_type = data_type;
prop.projection = projection;
prop.grid_spacing = grid_spacing;
prop.orbit_num_target_code_1 = orbit_num_target_code_1;
prop.orbit_num_target_code_2 = orbit_num_target_code_2;
prop.institution_id = institution_id;
prop.version = vr;

end