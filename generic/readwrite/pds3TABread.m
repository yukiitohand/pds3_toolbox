function [ data,colinfo2,colinfo_names ] = pds3TABread(fpath,obj_table,varargin)
% [ data,colinfo ] = pds3TABread(fpath,obj_table)
%   read pds3 formatted TAB (table) file
%    Input Parameters
%    fpath: file path to the table file '*.TAB'
%    obj_table: OBJECT_TABLE or some equivalent type of struct, contained
%               in lbl file. 
%    Output Parameters
%     data: struct, field names are defined in 'NAME' in each of struct in 
%           obj_table.OBJECT_COLUMN
%     colinfo: struct, field are same as the each element in
%              obj_table.OBJECT_COLUMN.
%     colinfo_names: struct, field are same as the each element in
%              obj_table.OBJECT_COLUMN, field names are colinfo(i).NAME for
%              easy access with their names.
%    Optional Parameters
%     'SKIPLINE': number of lines to be skipped
%             (default) 0
%     'MODE': 'normal' or 'fast'
%             (default) 'normal'
%             if 'fast' is selected, then all the data types are assumed to
%             be ASCII_REAL.

skip_line = 0;
readmode = 'normal';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'SKIP_LINE'
                skip_line = varargin{i+1};
            case 'MODE'
                readmode = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end



nCols = obj_table.COLUMNS;
nRows = obj_table.ROWS;
colinfo = obj_table.OBJECT_COLUMN;

if length(colinfo)==1
    colinfo = {colinfo};
end

nameList = cell(1,length(colinfo));

[name] = mod_fieldname(colinfo{1}.NAME);
nameList{1} = name;
data = struct(name,cell(nRows,1));

for c=2:nCols
    [name] = mod_fieldname(colinfo{c}.NAME);
    nameList{c} = name;
    [data.(name)] = deal([]);
end

switch lower(readmode)
    case 'normal'


        tab = repmat(' ', obj_table.ROWS,obj_table.ROW_BYTES);

        fp = fopen(fpath,'r');

        if skip_line>0
            for i=1:skip_line
                fgets(fp);
            end
        end

        for j=1:nRows
            tline = fgets(fp);
            L = length(tline);
            tab(j,1:L) = tline;
        end

        fclose(fp);

        % replace invalid_constant with nan added Yuki June 16, 2017
        for c=1:nCols
            strtbyte = colinfo{c}.START_BYTE;
            lastbyte = colinfo{c}.START_BYTE + colinfo{c}.BYTES-1;
            tabc = tab(:,strtbyte:lastbyte);
            switch colinfo{c}.DATA_TYPE
                case 'CHARACTER'
                    datac = cellstr(tabc);
                    for l=1:length(datac)
                        datac{l} = rmdq(datac{l},'both');
                    end
                    [data.(nameList{c})] = datac{:};
                case 'ASCII_REAL'
                    datac = cellstr(tabc);
                    datac_isnan = cellfun(@(x) strcmpi(strtrim(x),'"N/A"'),datac);
        %             if any(datac_isnan)
        %                 fprintf('%d\n',c);
        %             end
                    [datac{datac_isnan}] = deal('NaN');
                    datac = cellfun(@(x) str2double(x),datac);
                    datac = num2cell(datac);
                    [data.(nameList{c})] = datac{:};
                case {'INTEGER','ASCII_INTEGER'}
                    datac = cellstr(tabc);
                    datac_isnan = cellfun(@(x) strcmpi(strtrim(x),'"N/A"'),datac);
                    % for l=1:length(datac)
                    %     datac{l} = rmdq(datac{l},'both');
                    % end
                    [datac{datac_isnan}] = deal('NaN');
                    try
                        datac = cellfun(@(x) str2num(x),datac);
                        datac = num2cell(datac);
                    catch
                        fprintf('c:%d - Integer conversion error, string output\n',c);
                    end
                    [data.(nameList{c})] = datac{:};
                case 'TIME'
                    % yyyy-mm-ddThh:mm:ss.sss
                    datac = cellstr(tabc);
                    for l=1:length(datac)
                        datac{l} = rmdq(datac{l},'both');
                    end
                    [data.(nameList{c})] = datac{:};
                otherwise
                    error('c=%d,DATA_TYPE %s is not defined',c,colinfo{c}.DATA_TYPE);
            end

            % if isfield(colinfo{c},'INVALID_CONSTANT')
        %   %       fprintf('%d: Yes invalid constant.\n',c);
            %     nanidx = cellfun(@(x) x==colinfo{c}.INVALID_CONSTANT,datac);
            %     [data(nanidx).(nameList{c})] = deal(colinfo{c}.INVALID_CONSTANT);
            % end
        end
        
    case 'fast'
        fp = fopen(fpath,'r');
        if skip_line>0
            for i=1:skip_line
                fgets(fp);
            end
        end
        
        formatCell = repmat({' %f'},[1,nCols]);
        formatString = strjoin(formatCell,',');
        data_raw = textscan(fp,formatString,nRows);
        %for i=1:size(data,2)
        %    spc(:,i) = data{i};
        %end
        for c=1:nCols
            data_rawc = num2cell(data_raw{c});
            [data.(nameList{c})] = data_rawc{:};
        end

        fclose(fp);
    otherwise
        error('Undefined mode %s',readmode);
end

if length(colinfo)==1
    colinfo2 = colinfo;
else
    colinfo2 = merge_struct(colinfo{:});
end

colinfo_names = [];
for i=1:length(colinfo2)
    colinfo_names.(nameList{i}) = colinfo2(i);
end

end

function [name_m] = mod_fieldname(name)
if ~isempty(regexpi(name,'^[\d]+.*','ONCE'))
    name = ['COLNAME_' name];
end
name = replace(name,{',',' ',':','(',')'},'_');
name_m = replace(name,{';','^','/'},'');
end