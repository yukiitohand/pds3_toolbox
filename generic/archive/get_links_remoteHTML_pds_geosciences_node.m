function [lnks] = get_links_remoteHTML_pds_geosciences_node(html)
% [lnks] = get_links_remoteHTML_pds_geosciences_node(html)
%   match files in the html files obtained at the pds-geosciences node.
% Input
%   html: html text
% Output
%   lnks: struct having two fields
%     hyperlink: hyperlink, only the basename (or with extention) is read.
%                no slash will be attached
%     type     : type of the content at the link {'PARENTDIR','To Parent Directory','dir'}
%                if other types are specified, it will be regarded as a
%                file.

ptrn_lnk_file = '\s*(?<type>[\d]+)\s*<A HREF="(?<hyperlink>[^<>"]+)">';
ptrn_lnk_dir =  '\s*&lt;\s*(?<type>dir)\s*&gt;\s*<A HREF="(?<hyperlink>[^<>"]+)">';
%ptrn_parent_dir =  '<A HREF="(?<hyperlink>[^<>"]+)">.*\[(?<type>To Parent Directory)\].*';
lnks_file = regexpi(html,ptrn_lnk_file,'names');
lnks_dir = regexpi(html,ptrn_lnk_dir,'names');
lnks = merge_struct(lnks_file,lnks_dir);

for i=1:length(lnks)
    if strcmpi(lnks(i).type,'To Parent Directory')
        lnks(i)
    else
        lnk = strip(lnks(i).hyperlink,'right','/');
        [~,link_name,ext] = fileparts(lnk);
        link_name2 = [link_name ext];
        lnks(i).hyperlink = link_name2;
    end
end

end