function [BAND_STORAGE_TYPE] = envihdr_interleave2pds3_bst(interleave)
% [BAND_STORAGE_TYPE] = envihdr_interleave2pds3_bst(interleave)
%   Convert ENVI Header interleave to PDS3 BAND_STORAGE_TYPE.
%  INPUTS
%   interleave: char or string
%    'bil', 'bsq', ('bip')
%  OUTPUTS
%   BAND_STORAGE_TYPE: char or string,
%    'LINE_INTERLEAVED','BAND_SEQUENTIAL','BANDSEQUENTIAL'


switch upper(interleave)
    case 'BIL'
        BAND_STORAGE_TYPE = 'LINE_INTERLEAVED';
    case 'BSQ'
        BAND_STORAGE_TYPE = 'BAND_SEQUENTIAL';
    otherwise
        error('interleave: %s is not supported.',interleave);
end


end