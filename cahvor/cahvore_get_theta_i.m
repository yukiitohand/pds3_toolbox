function [theta,s] = cahvore_get_theta(cahvore_mdl,pmc,dim_pmc)
% [theta,s] = cahvore_get_theta(cahvore_mdl,pmc,dim_pmc)
%   Detailed explanation goes here

reshape_shape = ones(1,ndims(pmc));
reshape_shape(dim_pmc) = 3;
cahvore_O = reshape(cahvore_mdl.O,reshape_shape);

zeta = sum(cahvore_O.*pmc,dim_pmc);
lam = sqrt(sum((pmc - zeta.*cahvore_O).^2,dim_pmc));

theta = cahvore_get_theta_i_bisection_mex(zeta,lam,cahvore_mdl.E);

if nargout>1
    s = zeta - lam ./ tan(theta);
end

end
