function [xy_ap] = cahvor_get_apparent_xy_from_xy_cameracoord(xy,cmmdl)

if all(size(xy) == [1,2])
    xy = reshape(xy,[],1);
    xy_is_rowvec = 1;
else
    xy_is_rowvec = 0;
end

Nxy = size(xy,2);
pd = cat(1,ones(1,Nxy),(xy-[cmmdl.hc;cmmdl.vc])./[cmmdl.hs;cmmdl.vs]);

R = cat(1,cmmdl.A,cmmdl.Hdash,cmmdl.Vdash);
RO = cmmdl.O*R';

pd_nrmd = pd ./ (RO*pd);

klambda = pd_nrmd-RO';

klambda_mag = sqrt(sum(klambda.^2,1));

lambda_mag = cahvor_get_lambda_bisection(klambda_mag,cmmdl.R);

p = (lambda_mag./klambda_mag).*klambda + RO';

RA  = [1 0 0];
RHd = [0 1 0];
RVd = [0 0 1];
RH = cmmdl.hs*RHd + cmmdl.hc*RA;
RV = cmmdl.vs*RVd + cmmdl.vc*RA;

RHV = [RH;RV];

xy_ap = (RHV*p) ./ (RA*p);

if xy_is_rowvec
    xy_ap = reshape(xy_ap,1,[]);
end

end