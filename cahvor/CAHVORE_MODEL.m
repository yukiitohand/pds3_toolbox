classdef CAHVORE_MODEL < CAHVOR_MODEL
    % CAHVORE CAMERA model class
    %  CAHVORE model information stored. You can only have CAHV or CAHVOR. 
    %  Properties
    %   C, A, H, V, O, R, E: model components. 1x3 vector.
    %   T: type of the CAHVORE model
    %     1 - perspective lens
    %     2 - fisheye lens
    %     3 - a general model
    %   P: parameter of the CAHVORE model
    %     1 for T=1, 0 for T=2, and any value for T=3
    %   type: type of the model {'CAHV','CAHVOR','CAHVORE'}
    %   
    
    properties
        E
        T
        P
    end
    
    methods
        function obj = CAHVORE_MODEL(varargin)
            obj.C = []; obj.A = []; obj.H = []; obj.V = []; obj.O = [];
            obj.R = []; obj.E = []; obj.T = []; obj.P = [];
            if (rem(length(varargin),2)==1)
                error('Optional parameters should always go by pairs');
            else
                for i=1:2:(length(varargin)-1)
                    switch upper(varargin{i})
                        case {'C','CENTER'}
                            obj.C = reshape(varargin{i+1},1,[]);
                        case {'A','AXIS'}
                            obj.A = reshape(varargin{i+1},1,[]);
                        case {'H','HORIZONTAL'}
                            obj.H = reshape(varargin{i+1},1,[]);
                        case {'V','VERTICAL'}
                            obj.V = reshape(varargin{i+1},1,[]);
                        case {'O','OPTICAL'}
                            if ~isempty(varargin{i+1})
                                obj.O = reshape(varargin{i+1},1,[]);
                            end
                        case {'R','RADIAL'}
                            if ~isempty(varargin{i+1})
                                obj.R = reshape(varargin{i+1},1,[]);
                            end
                        case {'E','ENTRANCE-PUPIL_TERMS'}
                            if ~isempty(varargin{i+1})
                                obj.E = reshape(varargin{i+1},1,[]);
                            end
                        case {'T','TYPE'}
                            if ~isempty(varargin{i+1})
                                obj.T = reshape(varargin{i+1},1,[]);
                            end
                        case {'P','PARAMETER'}
                            if ~isempty(varargin{i+1})
                                obj.P = reshape(varargin{i+1},1,[]);
                            end
                        case {'REFERENCE_COORD_SYSTEM'}
                            obj.REFERENCE_COORD_SYSTEM = varargin{i+1};
                        otherwise
                            error('Parameter: %s', varargin{i});   
                    end
                end
            end
            if ~isempty(obj.O) && ~isempty(obj.R) && ~isempty(obj.E) && ~isempty(obj.T) % && ~isempty(obj.P)
                obj.type = 'CAHVORE';
            elseif ~isempty(obj.O) && ~isempty(obj.R) && isempty(obj.E) && isempty(obj.T) && isempty(obj.P)
                obj.type = 'CAHVOR';
            elseif isempty(obj.O) && isempty(obj.R) && isempty(obj.E) && isempty(obj.T) && isempty(obj.P)
                obj.type = 'CAHV';
            else
                error('Ambiguity in the input.');
            end
        end
        function tf = eq(obj1,obj2)
            if all(obj1.C == obj2.C) ...
                && all(obj1.A == obj2.A) ...
                && all(obj1.H == obj2.H) ...
                && all(obj1.V == obj2.V) ...
                && all(obj1.O == obj2.O) ...
                && all(obj1.R == obj2.R) ...
                && all(obj1.E == obj2.E) ...
                && all(obj1.T == obj2.T) ...
                && all(obj1.P == obj2.P)
                tf = true;
            else
                tf = false;
            end
        end
        function tf = ne(obj1,obj2)
            if (all(obj1.C ~= obj2.C)) ...
                || (all(obj1.A ~= obj2.A)) ...
                || (all(obj1.H ~= obj2.H)) ...
                || (all(obj1.V ~= obj2.V)) ...
                || (all(obj1.O ~= obj2.O)) ...
                || (all(obj1.R ~= obj2.R)) ...
                || (all(obj1.E ~= obj2.E)) ...
                || (all(obj1.T ~= obj2.T)) ...
                || (all(obj1.P ~= obj2.P))
                tf = true;
            else
                tf = false;
            end
        end
        
%         function [hc,vc] = get_optical_center_pixel(obj)
%             hc = (obj.A*obj.H'); %./norm(obj.A); (A should be normalized)
%             vc = (obj.A*obj.V'); %./norm(obj.A); (A should be normalized)
%             obj.hc = hc; obj.vc = vc;
%         end
%         
%         function [hs,vs] = get_pixel_focal_length(obj)
%             hs = norm(cross(obj.A,obj.H'));
%             vs = norm(cross(obj.A,obj.V'));
%             obj.hs = hs; obj.vs = vs;
%         end
%         
%         function [Hdash,Vdash,hs,vs,hc,vc] = get_image_plane_unit_vectors(obj)
%             [hc,vc] = obj.get_optical_center_pixel();
%             [hs,vs] = obj.get_pixel_focal_length();
%             Hdash = (obj.H-hc*obj.A) / hs;
%             Vdash = (obj.V-vc*obj.A) / vs;
%             obj.Hdash = Hdash;
%             obj.Vdash = Vdash;
%         end
%         
%         function [xy] = get_xy_from_pd_minus_c(obj,pdmc)
%             [xy] = cahv_get_xy_from_p_minus_c(pdmc,obj);
%         end
%         
%         function [p_minus_c] = get_pd_minus_c_from_xy(obj,xy)
%             [p_minus_c] = cahv_get_p_minus_c_from_xy_v2(xy,obj);
%         end
%         
%         function [p_minus_c] = get_p_minus_c_from_xy(obj,xy)
%             [p_minus_c] = cahvor_get_p_minus_c_from_xy_v2(xy,obj);
%         end
%         
%         function [xy_ap] = get_apparent_xy_from_xy(obj,xy)
%             [pmc] = obj.get_p_minus_c_from_xy(xy);
%             [xy_ap] = cahv_get_xy_from_p_minus_c(pmc,obj);
%         end
    end
end