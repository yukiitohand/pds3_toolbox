function [xy] = cahvore_get_xy(cahvore_mdl,p,dimp)

pmc = p - cahvore_mdl.C;
theta = cahvore_get_theta_i(cahvore_mdl,pmc);
chi = chavore_get_chi(theta,cahvore_mdl);


end