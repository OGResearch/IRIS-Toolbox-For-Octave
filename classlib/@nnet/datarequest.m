function varargout = datarequest(Req,This,Data,Range)
% datarequest  [Not a public function] Request data from database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Loop over requests
ReqSplit = regexp(Req,',','split') ;
nReq = numel(ReqSplit) ;
varargout = cell(1,nReq) ;
for iReq=1:nReq
    varargout{iReq} = db2tseries(Data,This.(ReqSplit{iReq}),Range) ;
end

end
