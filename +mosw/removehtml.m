function [Msg,args] = removehtml(Msg,args)
% removehtml [Not a public function] Remove HTML tags from message before printing.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% process args
fSpecPos = regexp(Msg,'%[^%]','start');
nSpec = length(fSpecPos);
[openTagPos,closeTagPos] = regexp(Msg,'<a[^<]*>','start','end');
nTags = length(openTagPos);
ix = any(repmat(fSpecPos,nTags,1)>repmat(openTagPos',1,nSpec) & ...
         repmat(fSpecPos,nTags,1)<repmat(closeTagPos',1,nSpec),1);

% remove args contained into tags
args(ix) = [];
         
% remove tags
Msg = regexprep(Msg,'<a[^<]*>','');
Msg = strrep(Msg,'</a>','');

end
