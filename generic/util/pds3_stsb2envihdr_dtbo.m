function [data_type,byte_order] = pds3_stsb2envihdr_dtbo(...
    SAMPLE_TYPE,SAMPLE_BITS)
% [data_type,byte_order] = pds3_stsb2envihdr_dtbo(...
%     SAMPLE_TYPE,SAMPLE_BITS)
%  Convert PDS3 SAMPLE_TYPE and SAMPLE_BITS to ENVI Header DATA_TYPE and
%  BYTE_ORDER
%  INPUTS:
%   SAMPLE_TYPE: char, string
%     'PC_REAL', 'IEEE_REAL', 'MSB_UNSIGNED_INTEGER','LSB_UNSIGNED_INTEGER'
%     'MSB_INTEGER', 'LSB_INTEGER', 'PC_COMPLEX', 'IEEE_COMPLEX'
%   SAMPLE_BITS; scalar
%     Either 8,16,32,64
%  OUTPUTS
%   data_type: scalar
%   byte_order: 0 (least significant bit first)
%               1 (most significant bit first)
%
% -----
% Note
% -----
% PDS3 SAMPLE_TYPE
% Reference: 
%  https://pds.jpl.nasa.gov/datastandards/pds3/standards/sr/Chapter03.pdf
% ENVI Header data type
%  1 = Byte: 8-bit unsigned integer
%  2 = Integer: 16-bit signed integer
%  3 = Long: 32-bit signed integer
%  4 = Floating-point: 32-bit single-precision
%  5 = Double-precision: 64-bit double-precision floating-point
%  6 = Complex: Real-imaginary pair of single-precision floating-point
%  9 = Double-precision complex: Real-imaginary pair of double precision 
%      floating-point
% 12 = Unsigned integer: 16-bit
% 13 = Unsigned long integer: 32-bit
% 14 = 64-bit long integer (signed)
% 15 = 64-bit unsigned long integer (unsigned)
%
% Reference:
%  https://www.l3harrisgeospatial.com/docs/ENVIHeaderFiles.html

switch upper(SAMPLE_TYPE)
    case {'PC_REAL'}
        byte_order = 0;
        switch SAMPLE_BITS
            case 32
                data_type = 4; % single, float
            case 64
                data_type = 5; % double
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
        
    case {'IEEE_REAL','REAL','MAC_REAL','SUN_REAL'}
        byte_order = 1;
        switch SAMPLE_BITS
            case 32
                data_type = 4; % single, float
            case 64
                data_type = 5; % double
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
        
    case {'MSB_UNSIGNED_INTEGER','UNSIGNED_INTEGER',...
            'MAC_UNSIGNED_INTEGER','SUN_UNSIGNED_INTEGER'}
        byte_order = 1;
        switch SAMPLE_BITS
            case 8
                data_type = 1;  % uint8
            case 16
                data_type = 12; % uint16
            case 32
                data_type = 13; % uint32
            case 64
                data_type = 15; % uint64
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
        
    case {'LSB_UNSIGNED_INTEGER','PC_UNSIGNED_INTEGER',...
            'VAX_UNSIGNED_INTEGER'}
        byte_order = 0;
        switch SAMPLE_BITS
            case 8
                data_type = 1;  % uint8
            case 16
                data_type = 12; % uint16
            case 32
                data_type = 13; % uint32
            case 64
                data_type = 15; % uint64
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
    case {'MSB_INTEGER','INTEGER','MAC_INTEGER','SUN_INTEGER'}
        byte_order = 1;
        switch SAMPLE_BITS
            case 16
                data_type = 2;  % int16
            case 32
                data_type = 3;  % int32
            case 64
                data_type = 14; % int64
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
    case {'LSB_INTEGER','PC_INTEGER','VAX_INTEGER'}
        byte_order = 0;
        switch SAMPLE_BITS
            case 16
                data_type = 2;  % int16
            case 32
                data_type = 3;  % int32
            case 64
                data_type = 14; % int64
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
        
    case 'PC_COMPLEX'
        byte_order = 0;
        switch SAMPLE_BITS
            case 32
                data_type = 6; % single precision complex
            case 64
                data_type = 9; % double precision complex
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
        
    case {'IEEE_COMPLEX','COMPLEX','MAC_COMPLEX','SUN_COMPLEX'}
        byte_order = 1;
        switch SAMPLE_BITS
            case 32
                data_type = 6; % single precision complex
            case 64
                data_type = 9; % double precision complex
            otherwise
                error('Undefined "SAMPLE_BITS" %d for SAMPLE_TYPE %s',...
                    SAMPLE_BITS,SAMPLE_TYPE);
        end
    otherwise
        error('The data type: %s is not supported yet.',SAMPLE_TYPE);
end

end