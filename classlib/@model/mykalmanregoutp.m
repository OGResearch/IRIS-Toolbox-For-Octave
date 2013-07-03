function [F,Pe,V,Delta,PDelta,SampleCov,This] ...
    = mykalmanregoutp(This,RegOutp,XRange,LikOpt)
% mykalmanregoutp  [Not a public function] Post-process regular (non-hdata) output arguments from the Kalman filter or FD lik.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

template = tseries();

F = [];
if isfield(RegOutp,'F');
    F = template;
    F = replace(F,permute(RegOutp.F,[3,1,2,4]),XRange(1));
end

Pe = [];
if isfield(RegOutp,'Pe')
    Pe = struct();
    for iName = find(This.nametype == 1)
        name = This.name{iName};
        data = permute(RegOutp.Pe(iName,:,:),[2,3,1]);
        if This.log(iName)
            data = exp(data);
        end
        Pe.(name) = template;
        Pe.(name) = replace(Pe.(name),data,XRange(1),name);
    end
end

V = [];
if isfield(RegOutp,'V')
    V = RegOutp.V;
end

Delta = struct();
deltaList = This.name(LikOpt.outoflik);
if isfield(RegOutp,'Delta')
    for i = 1 : length(LikOpt.outoflik)
        name = deltaList{i};
        namePos = LikOpt.outoflik(i);
        This.Assign(1,namePos,:) = RegOutp.Delta(i,:);
        Delta.(name) = RegOutp.Delta(i,:);
    end
end

PDelta = [];
if isfield(RegOutp,'PDelta')
    PDelta = namedmat(RegOutp.PDelta,deltaList,deltaList);
end

SampleCov = [];
if isfield(RegOutp,'SampleCov')
    eList = This.name(This.nametype == 3);
    SampleCov = namedmat(RegOutp.SampleCov,eList,eList);
end

% Update the std parameters in the model object.
if LikOpt.relative && nargout > 6
    ne = sum(This.nametype == 3);
    nAlt = size(This.Assign,3);
    nv = length(V);
    if nv > nAlt
        This(end+1:nv) = This(end);
    end
    se = sqrt(V);
    for iAlt = 1 : nAlt
        This.stdcorr(1,1:ne,iAlt) = This.stdcorr(1,1:ne,iAlt)*se(iAlt);
    end
    % Refresh dynamic links after we change std deviations because std devs are
    % allowed in dynamic links.
    if ~isempty(This.Refresh)
        This = refresh(This);
    end
end

end