classdef HiRISEdata < HSI
    %HiRISEdata
    %   For any type of HiRISE data
    
    properties
        lblpath;
        lbl;
        isimg = false;
        istab = false;
        missing_constant_img
        prop = [];
        data_class = [];
        dirname;
        cylindrical_proj_info;
        latitude;
        longitude
    end
    
    methods
        function obj = HiRISEdata(basename,dirpath,varargin)
            if ~isempty(hirise_getProp_basenameDTM(basename))
                prop = hirise_getProp_basenameDTM(basename);
                data_class = 'DTM';
            else
                error('only DTM class is supported for now');
            end
            
            % currently directory estimate is not implemented yet.
            dirpath = '/Volumes/LaCie/data/hirise/';
            
            obj@HSI(basename,dirpath,varargin{:});
            % [obj.lblpath] = guessLBLPATH(basename,dirpath,varargin{:});
            obj.prop = prop;
            obj.data_class = data_class;
            
            obj.readlblhdr();
            obj.get_cylindrical_proj_info();
        end
        
        function get_cylindrical_proj_info(obj)
            [obj.cylindrical_proj_info,obj.longitude,obj.latitude] = hiriseDTM_get_cylindrical_proj_info(obj.lbl);
        end
        
        function [] = readlblhdr(obj)
            switch obj.data_class
                case 'DTM'
                    obj.lbl = pds3lblread(obj.imgpath);
                    obj.hdr = hirise_lbl2hdr(obj.lbl);
                case 'ORTHOIMAGE'
                    error('not implemented yet');
            end
        end
        
        function [img] = readimg(obj)
            if isempty(obj.hdr)
                error('no img is found');
            end
            img = envidataread_v2(obj.imgpath,obj.hdr);
            img(img<obj.lbl.OBJECT_IMAGE.VALID_MINIMUM) = nan;
            img(img>obj.lbl.OBJECT_IMAGE.VALID_MAXIMUM) = nan;
            if nargout<1
                obj.img = img;
                obj.is_img_band_inverse = false;
            end
        end
        
        function [img] = readimgi(obj)
            % read image and invert the band order
            img = obj.readimg();
            img = img(:,:,end:-1:1);
            if nargout==0
                obj.img = img;
                obj.is_img_band_inverse = true;
            end
        end
        
        function [subimg,xrange,yrange] = get_subimage_wlatlon(obj,lon_range,lat_range,varargin)
            s1 = max(1,floor((lon_range(1)-obj.cylindrical_proj_info.lon_range(1))*obj.cylindrical_proj_info.rdlon));
            send = min(obj.hdr.samples,ceil((lon_range(2)-obj.cylindrical_proj_info.lon_range(1))*obj.cylindrical_proj_info.rdlon)+1);
            l1 = max(1,floor((obj.cylindrical_proj_info.lat_range(1)-lat_range(1))*obj.cylindrical_proj_info.rdlat));
            lend = min(obj.hdr.lines,ceil((obj.cylindrical_proj_info.lat_range(1)-lat_range(2))*obj.cylindrical_proj_info.rdlat)+1);
            sample_offset = s1-1;
            line_offset = l1-1;
            samplesc = send-s1+1;
            linesc = lend-l1+1;
            [subimg] = hirise_lazyenvireadRect_mexw(obj,...
                sample_offset,line_offset,samplesc,linesc,varargin{:});
            subimg(subimg<obj.lbl.OBJECT_IMAGE.VALID_MINIMUM) = nan;
            subimg(subimg>obj.lbl.OBJECT_IMAGE.VALID_MAXIMUM) = nan;
            xrange = [s1 send];
            yrange = [l1 lend];
        end
        
    end
end