function [krnl_info] = spice_textkernel_read(fpath_krnl)
% [krnl_info] = spice_textkernel_read(fpath_krnl)
%   read a text kernel file and 

fid = fopen(fpath_krnl);
krnl_info = []; zzz = []; krnl_text = [];

ptrn_bgndata = '^\s*\\begindata\s*';
ptrn_bgntxt = '^\s*\\begintext\s*';
ptrn_line = '^\s*(?<param>[^=\s]+)\s*=\s*(?<value>(\S+.*\S+|\S*))\s*$';
ptrn_braceboth = '^\s*\((?<content>.*)\)\s*$';
ptrn_braceleft = '^\s*\((?<content>.*)$';
ptrn_braceright = '^(?<content>.*)\)\s*$';
ptrn_strnum = '^\s*[-]{0,1}\d*\.{0,1}\d*[e]{0,1}[\+-]{0,1}\d*\s*$';
ptrn_ws = '^\s*$';

ptrn_param_negative_replace = '?<id_neg>-)\d+_\S+';

line_status = 'text';

flg_end = 0;
while ~feof(fid) && ~flg_end
    tline = fgetl(fid);
    if ischar(tline) && ~isempty(tline)
        if ~isempty(regexp(tline,ptrn_bgndata,'ONCE'))
            line_status = 'data';
        elseif ~isempty(regexp(tline,ptrn_bgntxt,'ONCE'))
            line_status = 'text';
        else
            switch line_status
                case 'data'
                    mtch_line = regexp(tline,ptrn_line,'names','once');
                    if ~isempty(mtch_line) % ' param = value '
                        param = mtch_line.param;
                        param_ori = param;
                        param = replace(param,{' ','-',':'},'_');
                        param = replace(param,{';','^'},'');
                        value_ori = mtch_line.value;
                        fprintf('%s --> %s\n',param_ori,param);
                        
                        mtch_braceleft = regexp(value_ori,ptrn_braceleft,'ONCE','names');
                        if isempty(mtch_braceleft)
                            [ value ] = rmquotes( value_ori );
                            if regexp(value,ptrn_strnum,'once')
                                % value = sscanf(value,'%f');
                                value = str2num(value);
                            elseif strcmpi(value,'N/A')
                                value = NaN;
                            elseif strcmpi(value,'NULL')
                                value = NaN;
                            end
                        else
                            mtch_braceboth = regexp(value_ori,ptrn_braceboth,'ONCE','names');
                            if ~isempty(mtch_braceboth)
                                value = mtch_braceboth.content;
                                % value = sscanf(value,'%f,');
                                value = str2num(value);
                                value = reshape(value,1,[]);
                            else
                                value = mtch_braceleft.content;
                                if regexp(value,ptrn_ws,'once')
                                    value = '';
                                end
                                mtch_braceright = [];
                                while isempty(mtch_braceright)
                                    tline = fgetl(fid);
                                    if isempty(regexp(tline,ptrn_ws,'once')) && ~isempty(tline)
                                        mtch_braceright = regexp(tline,ptrn_braceright,'ONCE','names');
                                        if isempty(mtch_braceright)
                                            if (size(value,2) == length(tline)) || isempty(value)
                                                value = [value; tline];
                                            else
                                                value = [value; {tline}];
                                            end
                                        else
                                            if isempty(regexp(mtch_braceright.content,'^\s*$','once'))
                                                if (size(value,2) == length(mtch_braceright.content)) || isempty(value)
                                                    value = [value; mtch_braceright.content];
                                                else
                                                    value = [value; {mtch_braceright.content}];
                                                end
                                            end

                                        end
                                    end
                                end
                                if ischar(value)
                                    value_nume = str2num(value);
                                    if ~isempty(value_nume)
                                        value = value_nume;
                                    end
                                elseif iscell(value)
                                    value = cellfun(@(x) str2num(x),value,'UniformOutput',false);
                                    if length(unique(cellfun(@(x) length(x),value)))==1
                                        value = cell2mat(value);
                                    else
                                        value = [value{:}];
                                    end
                                end
                            end
                        end
                        krnl_info.(param) = value;
                        zzz.(param) = param_ori;
                    end
                    
                case 'text'
                    % skip in case of text
                otherwise
                    error('Something wrong with line_status %s',line_status);
            end
        end
    end
end
krnl_info.zzz_original_field_names = zzz;

fclose(fid);
end
        
        