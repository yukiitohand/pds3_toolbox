function [xy] = cahv_get_xy_from_p_minus_c(pmc,cmmdl)

if all(size(pmc) == [1,3])
    pmc = reshape(pmc,[],1);
    pmc_is_rowvec = 1;
else
    pmc_is_rowvec = 0;
end

HV = [cmmdl.H;cmmdl.V];

xy =  (HV*(pmc)) ./ (cmmdl.A*(pmc));

if pmc_is_rowvec
    xy = reshape(xy,1,[]);
end

end