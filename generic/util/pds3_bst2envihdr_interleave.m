function [interleave] = pds3_bst2envihdr_interleave(BAND_STORAGE_TYPE)
% [interleave] = pds3_bst2envihdr_interleave(BAND_STORAGE_TYPE)
%   Convert PDS3 BAND_STORAGE_TYPE to ENVI Header interleave.
%  INPUTS
%   BAND_STORAGE_TYPE: char or string,
%    'LINE_INTERLEAVED','BAND_SEQUENTIAL','BANDSEQUENTIAL'
%  OUTPUTS
%   interleave: char or string
%    'bil', 'bsq', ('bip')


switch upper(BAND_STORAGE_TYPE)
    case 'LINE_INTERLEAVED'
        interleave = 'bil';
    case {'BAND_SEQUENTIAL','BANDSEQUENTIAL'}
        interleave = 'bsq';
    otherwise
        error('BAND_STORAGE_TYPE: %s is not supported.',BAND_STORAGE_TYPE);
end


end