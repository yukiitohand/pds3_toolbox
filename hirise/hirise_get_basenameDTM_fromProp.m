function [basenameDTM] = hirise_get_basenameDTM_fromProp(prop)
% [basenameDTM] = hirise_get_basenameDTM_fromProp(prop)
%  return struct of HiRISE DTM data
% INPUT
%  prop: struct storing properties
%   data_class              
%   data_type               
%   projection              
%   grid_spacing            
%   orbit_num_target_code_1 
%   orbit_num_target_code_2 
%   institution_id          
%   version                 
% OUTPUT
%   product_id defined below.
% 
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

data_class = prop.data_class;
data_type = prop.data_type;
projection = prop.projection;
grid_spacing = prop.grid_spacing;
ontc1 = prop.orbit_num_target_code_1;
ontc2 = prop.orbit_num_target_code_2;
institution_id = prop.institution_id;
vr = prop.version;

if isnumeric(vr)
    vr = sprintf('%2d',vr);
end

% PRODUCT_ID = aabcd_xxxxxx_xxxx_yyyyyy_yyyy_Vnn
basenameDTM = sprintf('%s%s%s%s_%s_%s_%s%s',data_class,data_type,...
    projection,grid_spacing,ontc1,ontc2,institution_id,vr);
end
