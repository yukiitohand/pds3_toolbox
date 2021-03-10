function [lnks] = get_links_remoteHTML_naif_archive(html)
% [lnks] = get_links_remoteHTML_naif_archive(html)
%   match files in the html files obtained at the remote server of NAIF
%   archive server.
% Input
%   html: html text
% Output
%   lnks: struct having two fields
%     hyperlink: hyperlink, only the basename (or with extention) is read.
%                no slash will be attached
%     type     : type of the content at the link {'PARENTDIR','To Parent Directory','dir'}
%                if other types are specified, it will be regarded as a
%                file.
%     text     : text to which hyperlink is attached.

%
% src="/icons/back.gif" alt="[DIR]"> <a href="/pub/naif/MRO/kernels/">Parent Directory</a>                             -   
% <img src="/icons/text.gif" alt="[TXT]"> <a href="aareadme.txt">aareadme.txt</a>            15-Aug-2005 13:19  2.8K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_crism_v10.ti">mro_crism_v10.ti</a>        05-Jun-2007 11:42   56K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_ctx_v10.ti">mro_ctx_v10.ti</a>          08-Jun-2007 08:30   13K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_ctx_v11.ti">mro_ctx_v11.ti</a>          23-Aug-2012 11:31   16K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_hirise_v10.ti">mro_hirise_v10.ti</a>       08-Jun-2007 08:30   32K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_hirise_v11.ti">mro_hirise_v11.ti</a>       27-Feb-2009 08:11   33K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_hirise_v12.ti">mro_hirise_v12.ti</a>       24-May-2011 08:06   34K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_marci_v10.ti">mro_marci_v10.ti</a>        29-Nov-2007 15:59   32K  
% <img src="/icons/text.gif" alt="[TXT]"> <a href="mro_mcs_v10.ti">mro_mcs_v10.ti</a>          06-Jun-2007 08:47   56K  
% <img src="/icons/unknown.gif" alt="[   ]"> <a href="mro_onc_v10.ti">mro_onc_v10.ti</a>          05-Jun-2007 11:42   13K 

ptrn_lnk = '<img src="[^<>"]*" alt="\[(?<type>[^<>"]*)\]">\s*<a href="(?<hyperlink>[^<>"]+)">\s*(?<text>[^<>]*)\s*</a>';
lnks = regexpi(html,ptrn_lnk,'names');

% for i=1:length(lnks)
%     if strcmpi(lnks(i).text,'Parent Directory')
%         lnks(i);
%     else
%         % lnk = strip(lnks(i).hyperlink,'right','/');
%         % [~,link_name,ext] = fileparts(lnk);
%         % link_name2 = [link_name ext];
%         % lnks(i).hyperlink = link_name2;
%     end
% end

end