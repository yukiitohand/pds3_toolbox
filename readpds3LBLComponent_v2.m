function [isprm,param,value,param_ori] = readpds3LBLComponent_v2(fid)
ptrn_line = '^\s*(?<param>([\S[^=]]+[^=]*[\S[^=]]+|[\S[^=]]+))\s*=\s*(?<value>(\S+.*\S+|\S*))\s*$';
ptrn_dquoteboth = '^\s*"(?<string>[^""]*)"\s*$';
ptrn_dquoteleft = '^\s*".*$';
ptrn_braceboth = '^\s*\((?<string>[^\(\)]*)\)\s*$';
ptrn_braceleft = '^\s*\(.*$';
ptrn_curlyleft = '^\s*\{.*$';
ptrn_curlyboth = '^\s*\{(?<string>[^\{\}]*)\}\s*$';
ptrn_escape = '^[\s]*/\*.*\*/[\s]*$';

ptrn_array = '\s*(?<element>("[^""]*"|[^,]*))\s*,';
ptrn_withUnit = '^\s*(?<value>[-]*[\w\."]*)\s*(?<unit>[\<]{1}.*[\>]{1})$';
ptrn_comment = '\s*(?<value>.*[\S]+)\s*/[*].*[*]/';
% ptrn_ROWNUM_TABLE = '\s*"(?<filename>[^"]*)"\s*,\s*(?<offset>[0-9]+)\s*';
ptrn_END = '\s*END\s*$';
tline = fgetl(fid);

isprm = 0; param = []; value = []; param_ori = [];
if ischar(tline) && ~isempty(tline)
    if isempty(regexp(tline,ptrn_escape,'ONCE'))
        mtch_line = regexpi(tline,ptrn_line,'names');
        if ~isempty(mtch_line) % ' param = value '
            param = mtch_line.param;
            param_ori = param;
            value_orio = mtch_line.value;
            % replace any character that cannot be in the field names are
            % replaced.
            param = replace(param,{' ',':'},'_');
            param = replace(param,{';','^'},'');
            
            % strip any comment if it is attached at the end of the line.
            % Surrounded by /* */ like C.
            mtch_comment = regexpi(value_orio,ptrn_comment,'names');
            if ~isempty(mtch_comment)
                value_ori = mtch_comment.value;
            else
                value_ori = value_orio;
            end
            
            % if whole value is in the next line, read next
            while isempty(value_ori)
                tline = fgetl(fid);
                value_orio = strtrim(tline);
                mtch_comment = regexpi(value_orio,ptrn_comment,'names');
                if ~isempty(mtch_comment)
                    value_ori = mtch_comment.value;
                else
                    value_ori = value_orio;
                end
            end

            % match any curly is detected or not.
            mtch_curlyleft = regexpi(value_ori,ptrn_curlyleft,'ONCE');
            if ~isempty(mtch_curlyleft) % {...}
                mtch_curlyboth = regexpi(value_ori,ptrn_curlyboth,'names');
                if ~isempty(mtch_curlyboth)
                    value = mtch_curlyboth.string;
                    isprm = 1;
                else
                    while isempty(mtch_curlyboth)
                        tline = fgetl(fid);
                        value_ori = [value_ori,' ', strtrim(tline)];
                        mtch_curlyboth = regexpi(value_ori,ptrn_curlyboth,'names');
                    end
                    value = mtch_curlyboth.string;
                    isprm = 1;
                end
                % split into element
                value = [value ','];
                ptrn_array = '\s*(?<element>("[^""]*"|[^,]*))\s*,';
                value = regexpi(value,ptrn_array,'names');
                value = {value.element};
                % read each element
                for i=1:length(value)
                    value{i} = readLBL_valueElement(value{i});
                end
                % convert to numeric if all of the elements are numeric.
                if all(cellfun(@(x) isnumeric(x),value))
                    value = cell2mat(value);
                end
            else
                mtch_braceleft = regexpi(value_ori,ptrn_braceleft,'ONCE');
                if ~isempty(mtch_braceleft) % (...)
                    mtch_braceboth = regexpi(value_ori,ptrn_braceboth,'names');
                    if ~isempty(mtch_braceboth)
                        value = mtch_braceboth.string;
                        isprm = 1;
                    else
                        while isempty(mtch_braceboth)
                            tline = fgetl(fid);
                            value_ori = [value_ori,' ',strtrim(tline)];
                            mtch_braceboth = regexpi(value_ori,ptrn_braceboth,'names');
                        end
                        value = mtch_braceboth.string;
                        isprm = 1;
                    end
                    % % split into element
                    value = [value ','];
                    % ptrn_array = '\s*(?<element>("[^""]*"|[^,]*))\s*,';
                    value = regexpi(value,ptrn_array,'names');
                        value = {value.element};
                    for i=1:length(value)
                        value{i} = readLBL_valueElement(value{i});
                    end
                    % convert to numeric if all of the elements are numeric.
                    if all(cellfun(@(x) isnumeric(x),value))
                        value = cell2mat(value);
                    end
%                     mtch_ROWNUM_TABLE = regexpi(value_ori,ptrn_ROWNUM_TABLE,'names');
%                     if ~isempty(mtch_ROWNUM_TABLE)
%                         value_new{1} = rmdq(mtch_ROWNUM_TABLE.filename);
%                         value_new{2} = mtch_ROWNUM_TABLE.offset;
%                         t = str2num(value_new{2});
%                         if ~isempty(t), value_new{2} = t; end
%                         value = value_new;
%                     else
%                         value = strsplit(value,'"\s*,\s*"','DelimiterType','RegularExpression');
%                         for i=1:length(value)
%                             t = strtrim(value{i});
%                             value{i} = rmdq(t);
%                             t = str2num(value{i});
%                             if ~isempty(t),value{i} = t; end
%                         end
%                     end
                    
                else
                    % if double quotation exist on the left
                    mtch_dquoteleft = regexpi(value_ori,ptrn_dquoteleft,'ONCE');
                    if ~isempty(mtch_dquoteleft) % "..."
                        % if the format with unit follows,
                        mtch_wUnit = regexpi(value_ori,ptrn_withUnit,'names');
                        if ~isempty(mtch_wUnit)
                            value = readLBL_valueElement(value_ori);
                        else
                            % if right double quotation exists in the same
                            % line
                            mtch_dquoteboth = regexpi(value_ori,ptrn_dquoteboth,'names');
                            if ~isempty(mtch_dquoteboth)
                                value = mtch_dquoteboth.string;
                            else 
                                % if this continumes to be another line,
                                % read and concatenate until the double
                                % quotation is found
                                while isempty(mtch_dquoteboth)
                                    tline = fgetl(fid);
                                    value_ori = [value_ori,' ',strtrim(tline)];
                                    mtch_dquoteboth = regexpi(value_ori,ptrn_dquoteboth,'names');
                                end
                                value = mtch_dquoteboth.string;
                            end
                            value = readLBL_valueElement(value);
                        end
                    else
                        % last case.
                        value = readLBL_valueElement(value_ori);
                    end
                end
            end
            
%             else
%                 
%                 else
%                     
%                     else
%                         mtch_wUnit = regexpi(value_ori,ptrn_withUnit,'names');
%                         if ~isempty(mtch_wUnit)
%                             value{1} = rmdq(mtch_wUnit.value);
%                             t = str2num(value{1});
%                             if ~isempty(t), value{1} = t; end
%                             value{2}  = mtch_wUnit.unit;
%                             isprm = 1;
%                         else
%                             value = value_ori;
%                             t = str2num(value);
%                             if ~isempty(t), value = t; end
%                             
%                             isprm = 1;
%                         end
%                     end
%                 end
%             end
            isprm = 1;
        else
            if ~isempty(regexpi(tline,ptrn_END,'ONCE'))
                param = 'END';
            end
        end
    end
end


end


function [value] = readLBL_valueElement(value_raw)

% strip double quotation if exists.
value = rmdq(value_raw);

% convert to a numeric value if that is true
value_tmp = str2num(value);
if ~isempty(value_tmp)
    value = value_tmp;
elseif strcmpi(value,'N/A')
    value = NaN;
elseif strcmpi(value,'NULL')
    value = NaN;
else
    % test the value follows the format with a unit.
    ptrn_withUnit = '^\s*(?<value>[-]*[\w\."]*)\s*(?<unit>[\<]{1}.*[\>]{1})$';
    mtch_wUnit = regexpi(value_raw,ptrn_withUnit,'names');
    if ~isempty(mtch_wUnit)
        value1 = rmdq(mtch_wUnit.value);
        % convert to a numeric value if that is true
        value_tmp = str2num(value1);
        if ~isempty(value_tmp)
            value1 = value_tmp;
        elseif strcmpi(value1,'N/A')
            value1 = NaN;
        elseif strcmpi(value1,'NULL')
            value1 = NaN;
        else
            value1 = value_tmp;
        end
        value2 = mtch_wUnit.unit;
        
        value = [];
        value.value = value1;
        value.unit  = value2;
    end
end






end

