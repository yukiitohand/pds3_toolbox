classdef MOLA_MEGTRdata < ENVIRasterSingleLayerEquirectProjRot0
    % The MGS MOLA Mission Experiment Gridded Data Record (MEGDR)
    %   
    
    properties
        prop
        lbl
        lblpath
    end
    
    methods
        function obj = MOLA_MEGTRdata(basename,dirpath,varargin)
            % 
            propMEGDR = mola_getProp_basenameMEGDR(basename);
            if isempty(dirpath)
                [dirpath] = mola_megdr_get_dirpath_fromProp(propMEGDR);
            end
            obj@ENVIRasterSingleLayerEquirectProjRot0(basename,dirpath,...
                varargin{:});
            obj.lblpath = joinPath(dirpath,[basename '.lbl']);
            obj.lbl = pds3lblread(obj.lblpath);
            obj.hdr = mola_megdr_lbl2hdr(obj.lbl);
            obj.prop = propMEGDR;
            obj.get_proj_info();
        end
        
        function get_proj_info(obj)
            [obj.proj_info] = mola_megdr_get_cylindrical_proj_info(obj.lbl);
        end
        
        function [subimg] = get_subimage_wPixelRange(obj,xrange,yrange,varargin)
            [subimg] = get_subimage_wPixelRange@ENVIRasterSingleLayerEquirectProjRot0(...
                obj,xrange,yrange,'Precision','int16',varargin{:});
        end
        
        
        
    end
end

