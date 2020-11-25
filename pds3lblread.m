function [lbl_info,posend] = pds3lblread(fpth_lbl)
% read a general pds3 lbl file
%   Input parameters
%     fpth_lbl: file path to the label file
%   Output parameters
%     lbl_info: struct with many fields (all the item in the file)
 
fid = fopen(fpth_lbl);
lbl_info = []; zzz = [];
flg_end = 0;
while ~feof(fid) && ~flg_end
    [isprm,param,value,param_ori] = readpds3LBLComponent_v2(fid);
    if isprm 
        switch upper(param)
            case 'OBJECT'
                % [obj,obj_name] = readObject(fid,value);
                [obj,obj_name] = readNested(fid,value,'OBJECT');
                if isfield(lbl_info,obj_name)
                    if length(lbl_info.(obj_name))==1
                        lbl_info.(obj_name) = {lbl_info.(obj_name)};
                    end
                    lbl_info.(obj_name) = [lbl_info.(obj_name), {obj}];
                else
                    lbl_info.(obj_name) = obj;
                end
            case 'GROUP'
                [grp,grp_name] = readNested(fid,value,'GROUP');
                if isfield(lbl_info,grp_name)
                    if length(lbl_info.(grp_name))==1
                        lbl_info.(grp_name) = {lbl_info.(grp_name)};
                    end
                    lbl_info.(grp_name) = [lbl_info.(grp_name), {grp}];
                else
                    lbl_info.(grp_name) = grp;
                end
                
            otherwise
                lbl_info.(param) = value;
                zzz.(param) = param_ori;
        end
    else
        if strcmpi(param,'END') % finish if it is end
            flg_end = 1;
        end
    end
end
lbl_info.zzz_original_field_names = zzz;
posend = ftell(fid);
fclose(fid);

end

function [obj,obj_name] = readNested(fid,obj_value,classname_nested)
    obj_name = [classname_nested '_' obj_value];
    obj = []; zzz = [];
    flg = 1;
    while flg
        [isprm,param,value,param_ori] = readpds3LBLComponent_v2(fid);
        if isprm
            if strcmp(param,classname_nested)
                [child,child_name] = readNested(fid,value,classname_nested);
                if isfield(obj,child_name)
                    if length(obj.(child_name))==1
                        obj.(child_name) = {obj.(child_name)};
                    end
                    obj.(child_name) = [obj.(child_name), {child}];
                else
                    obj.(child_name) = child;
                end
            else
                if strcmp(param,['END_' classname_nested]) && strcmp(value,obj_value)
                    flg = 0;
                else
                    obj.(param) = value;
                    zzz.(param) = param_ori;
                end
            end
        end
        if strcmp(param,['END_' classname_nested]) && strcmp(value,obj_value)
            flg=0;
        end
    end
    obj.zzz_original_field_names = zzz;
end
