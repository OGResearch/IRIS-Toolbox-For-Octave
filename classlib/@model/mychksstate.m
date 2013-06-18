function [Discr,MaxAbsDiscr,Flag,List] = mychksstate(This,Opt)
% mychksstate  [Not a public function] Discrepancy in steady state of model equtions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% The input struct Opt is expected to include
%
% * `.sstateeqtn` -- switch between evaluating full dynamic versus
% steady-state equations;
% * `.tolerance` -- tolerance level.

%--------------------------------------------------------------------------

nEqtnXY = sum(This.eqtntype <= 2);
nAlt = size(This.Assign,3);

Flag = false(1,nAlt);
List = cell(1,nAlt);

if ~Opt.sstateeqtn
    doDynamicEqtn();
else
    doSstateEqtn();
end

MaxAbsDiscr = max(abs(Discr),[],2);
for iAlt = 1 : nAlt
    inx = abs(MaxAbsDiscr(:,iAlt)) <= Opt.tolerance;
    Flag(iAlt) = all(inx == true);
    if ~Flag(iAlt) && nargout >= 4
        List{iAlt} = This.eqtn(~inx);
    else
        List{iAlt} = {};
    end
end

%**************************************************************************
    function doDynamicEqtn()
        % Check the full equations in two consecutive periods. This way we
        % can detect errors in both levels and growth rates.
        Discr = nan(nEqtnXY,2,nAlt);
        preSample = This.tzero - 1;
        if issparse(This.occur)
            nT = size(This.occur,2) / length(This.name);
        else
            nT = size(This.occur,3);
        end
        postSample = nT - This.tzero;
        nameYXEPos = find(This.nametype < 4);
        delog = true;
        iiAlt = Inf;
        for t = 1 : 2
            tVec = t + (-preSample : postSample);
            X = mytrendarray(This,nameYXEPos,tVec,delog,iiAlt);
            L = X(:,preSample+1,:);
            Discr(:,t,:) = lhsmrhs(This,X,L);
        end
    end % doDynamicEqtn().

%**************************************************************************
    function doSstateEqtn()
        Discr = nan(nEqtnXY,1,nAlt);
        eqtn = This.eqtnS(This.eqtntype <= 2);
        % Remove the `exp` transformation applied to log variables. Otherwise,
        % we would have to log the sstate vector, and it would get de-logged
        % again in the equations.
        eqtn = strrep(eqtn,'exp?','');
        % Create anonymous funtions for sstate equations.
        for ii = 1 : length(eqtn)
            eqtn{ii} = str2func(['@(x,dx) ',eqtn{ii}]);
        end
        for iiAlt = 1 : nAlt
            x = real(This.Assign(1,:,iiAlt));
            dx = imag(This.Assign(1,:,iiAlt));
            dx(This.log & dx == 0) = 1;
            Discr(:,iiAlt) = (cellfun(@(fcn) fcn(x,dx),eqtn)).';
        end
    end % doSstateEqtn().

end