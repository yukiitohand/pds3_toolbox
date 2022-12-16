function spice_pck_mars_overwrite_radii(radii,varargin)


switch length(radii)
    case 1
        radii = repmat(radii,[3,1]);
    case 3
        radii = radii(:);
    otherwise
        error('length of radii %d need to be 1 or 3.',length(radii));
end
cspice_pdpool('BODY499_RADII',radii);

end