function [F,Pe,V,Delta,PDelta,SampleCov,This] ...
    = mykalmanregoutp(This,RegOutp,XRange,LikOpt,Opt)
% mykalmanregoutp  [Not a public function] Post-process regular (non-hdata) output arguments from the Kalman filter or FD lik.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));
template = tseries();
isNamedMat = strcmpi(Opt.MatrixFmt,{'namedmat'});

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
        if This.IxLog(iName)
            data = realexp(data);
        end
        Pe.(name) = template;
        Pe.(name) = replace(Pe.(name),data,XRange(1),name);
    end
end

V = [];
if isfield(RegOutp,'V')
    V = RegOutp.V;
end

% Update out-of-lik parameters in the model object.
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
    PDelta = RegOutp.PDelta;
    if isNamedMat
        PDelta = namedmat(PDelta,deltaList,deltaList);
    end
end

SampleCov = [];
if isfield(RegOutp,'SampleCov')
    SampleCov = RegOutp.SampleCov;
    if isNamedMat
        eList = This.name(This.nametype == 3);
        SampleCov = namedmat(SampleCov,eList,eList);
    end
end

% Update the std parameters in the model object.
if LikOpt.relative && nargout > 6
    ne = sum(This.nametype == 3);
    nAlt = size(This.Assign,3);
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
