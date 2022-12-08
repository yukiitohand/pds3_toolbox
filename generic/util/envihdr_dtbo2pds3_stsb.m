function [SAMPLE_TYPE,SAMPLE_BITS] = envihdr_dtbo2pds3_stsb(...
    data_type,byte_order)
% [SAMPLE_TYPE,SAMPLE_BITS] = envihdr_dtbo2pds3_stsb(...
%     data_type,byte_order)
%  Convert ENVI Header DATA_TYPE and BYTE_ORDER to PDS3 SAMPLE_TYPE and SAMPLE_BITS
%  
%  INPUTS:
%   data_type: scalar
%   byte_order: 0 (least significant bit first)
%               1 (most significant bit first)
%
%  OUTPUTS
%   SAMPLE_TYPE: char, string
%     'PC_REAL', 'IEEE_REAL', 'MSB_UNSIGNED_INTEGER','LSB_UNSIGNED_INTEGER'
%     'MSB_INTEGER', 'LSB_INTEGER', 'PC_COMPLEX', 'IEEE_COMPLEX'
%   SAMPLE_BITS; scalar
%     Either 8,16,32,64
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

switch data_type
    case {4,5}
        switch byte_order
            case 0
                SAMPLE_TYPE = 'PC_REAL';
            case 1
                SAMPLE_TYPE = 'IEEE_REAL';
                % can be any of 
                % {'IEEE_REAL','REAL','MAC_REAL','SUN_REAL'}
            otherwise
                error('Undefined byte_order %d for data_type %d.',byte_order,data_type);
        end
        switch data_type
            case 4
                SAMPLE_BITS = 32; % single, float
            case 5
                SAMPLE_BITS = 64; % double
        end

    case {1,12,13,15}
        switch byte_order
            case 0
                SAMPLE_TYPE = 'PC_UNSIGNED_INTEGER';
                % can be any of 
                % {'LSB_UNSIGNED_INTEGER','PC_UNSIGNED_INTEGER',...
                % 'VAX_UNSIGNED_INTEGER'}
            case 1
                SAMPLE_TYPE = 'MSB_UNSIGNED_INTEGER';
                % can be any of 
                % {'MSB_UNSIGNED_INTEGER','UNSIGNED_INTEGER',...
                % 'MAC_UNSIGNED_INTEGER','SUN_UNSIGNED_INTEGER'}
            otherwise
                error('Undefined byte_order %d for data_type %d.',byte_order,data_type);
        end
        switch data_type
            case 1
                SAMPLE_BITS = 8;  % uint8
            case 12
                SAMPLE_BITS = 16; % uint16
            case 13
                SAMPLE_BITS = 32; % uint32
            case 15
                SAMPLE_BITS = 64; % uint64
        end

    case {2,3,14}
        switch byte_order
            case 0
                SAMPLE_TYPE = 'PC_INTEGER';
                % can be any of 
                % {'LSB_INTEGER','PC_INTEGER','VAX_INTEGER'}
            case 1
                SAMPLE_TYPE = 'MSB_INTEGER';
                % can be any of 
                % {'MSB_INTEGER','INTEGER','MAC_INTEGER','SUN_INTEGER'}
            otherwise
                error('Undefined byte_order %d for data_type %d.',byte_order,data_type);
        end
        switch data_type
            case 2
                SAMPLE_BITS = 16; % int16
            case 3
                SAMPLE_BITS = 32; % int32
            case 14
                SAMPLE_BITS = 64; % int64
        end

    case {6,9}
        switch byte_order
            case 0
                SAMPLE_TYPE = 'PC_COMPLEX';
                % can be any of 
            case 1
                SAMPLE_TYPE = 'IEEE_COMPLEX';
                % can be any of 
                % {'IEEE_COMPLEX','COMPLEX','MAC_COMPLEX','SUN_COMPLEX'}
            otherwise
                error('Undefined byte_order %d for data_type %d.',byte_order,data_type);
        end
        switch data_type
            case 6
                SAMPLE_BITS = 32; % single precision complex
            case 9
                SAMPLE_BITS = 64; % double precision complex
        end
end


end