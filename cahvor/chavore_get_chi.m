function [chi] = chavore_get_chi(theta,cahvore_mdl)

switch cahvore_mdl.T
    case 1 % perspective projection
        chi = tan(theta);
    case 2 % fisheye lens
        chi = theta;
    case 3 % general Linearity parameter L
        L = cahvore_mdl.P;
        chi = sin(L*theta) ./ (L*cos(max(0,L*theta)));
    otherwise
        error('Undefined CAHVORE MODEL TYPE: %d', cahvore_mdl.T);
end

end