function [sclk_str] = spice_sclk_num2str(sclk_num)
% [sclk_str] = spice_sclk_num2str(sclk_num)
%  Convert a numeric form of sclk to a valid char/string form for an input
%  to spice-mice functions.
%  INPUTS:
%    sclk_num: numeric sclk
%  OUTPUTS:
%    sclk_str: cell (if length(sclk_num)>1) of char (if sclk_num is a
%    scalar. Element is the form of 
%      xxx...x:sss...s
%    xxx...x : integer part of sclk
%    sss...s : integer representation of the decimal part of sclk. One
%    corrsponds to (1/2^16).
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
%

sclk_num_S  = floor(sclk_num);
sclk_num_SS = round((sclk_num-sclk_num_S)*65536);

if length(sclk_num)==1
    sclk_str = sprintf('%d:%d',sclk_num_S,sclk_num_SS);
else
    sclk_str = cellfun( @(x,y) sprintf('%d:%d',x,y), ...
        num2cell(sclk_num_S), num2cell(sclk_num_SS), ...
        'UniformOutput',false);
end

end