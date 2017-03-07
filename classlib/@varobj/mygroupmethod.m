function Outp = mygroupmethod(Func,This,Inp,varargin)
% mygroupmethod  [Not a public function] Implement varobj methods requiring input data for panel VARs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Empty input data are allowed in `resample`.
isEmptyInp = isempty(Inp);

%--------------------------------------------------------------------------

nGrp = length(This.GroupNames);
Outp = struct();
for iGrp = 1 : nGrp
    name = This.GroupNames{iGrp};
    iThis = group(This,name);
    if isEmptyInp
        iInp = [];
    else
        iInp = Inp.(name);
    end
    Outp.(name) = Func(iThis,iInp,varargin{:});
end

end