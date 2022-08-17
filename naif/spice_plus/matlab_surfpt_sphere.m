function [point,found] = matlab_surfpt_sphere(positn,u,a,varargin)
% multi vector version of cspice_surfpt for sphere
%  [point,found] = matlab_surfpt_sphere(positn,u,a,varargin)


if isempty(varargin)
    proc_opt = 'SPICE';
else
    proc_opt = varargin{1};
end

switch upper(proc_opt)
    case 'SPICE'
        
        N = size(u,2);
        point = nan(3,N);
        found = false(1,N);
        b = a; c = a;
        for i=1:N
            [point(:,i), found(:,i)] = cspice_surfpt(positn, u(:,i), a, b, c );
        end
    case 'SPICEMEX'
        b = a; c = a;
        [point, found] = cspice_surfpt_mex(positn, u, a, b, c );
    case 'MATLAB'
        
    otherwise
        error('Undeifined Processing Option %s',proc_opt);

end