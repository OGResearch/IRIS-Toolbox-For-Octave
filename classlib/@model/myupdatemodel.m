function [This,UpdateOk] = myupdatemodel(This,P,Pri,Opt,ThrowErr,ExpMat)
% myupdatemodel  [Not a public function] Update parameters, sstate, solve, and refresh.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    ThrowErr; %#ok<VUNUS>
catch %#ok<CTCH>
    ThrowErr = true;
end

try
    ExpMat; %#ok<VUNUS>
catch %#ok<CTCH>
    ExpMat = false;
end

%--------------------------------------------------------------------------

% TODO: Add a `'chksstate='` option. Create and supply a ready-to-use
% function or code that checks the sstate quickly.

assignPos = Pri.assignpos;
stdcorrPos = Pri.stdcorrpos;

assignNan = isnan(assignPos);
assignPos = assignPos(~assignNan);
stdcorrNan = isnan(stdcorrPos);
stdcorrPos = stdcorrPos(~stdcorrNan);

% Reset parameters and stdcorrs.
This.Assign = Pri.Assign;
This.stdcorr = Pri.stdcorr;

% Update regular parameters and run refresh if needed.
refreshed = false;
if any(~assignNan)
    This.Assign(1,assignPos) = P(~assignNan);
end

% Update stds and corrs.
if any(~stdcorrNan)
    This.stdcorr(1,stdcorrPos) = P(~stdcorrNan);
end

% Refresh dynamic links. The links can refer/define std devs and
% cross-corrs.
if Opt.refresh && ~isempty(This.Refresh)
    This = refresh(This);
    refreshed = true;
end

% If only stds or corrs have been changed, no values have been
% refreshed, and no user preprocessor is called, return immediately as
% there's no need to re-solve or re-sstate the model.
if all(assignNan) && ~isa(Opt.sstate,'function_handle') && ~refreshed
    UpdateOk = true;
    return
end

if This.linear
    % Linear models
    %---------------
    if Opt.solve
        [This,nPath,nanDeriv,sing2] = mysolve(This,1,[],ExpMat);
    else
        nPath = 1;
    end
    if isstruct(Opt.sstate)
        This = mysstatelinear(This);
        if Opt.refresh && ~isempty(This.Refresh)
            This = refresh(This);
        end
    end
    sstateOk = true;
    chkSstateOk = true;
else
    % Non-linear models
    %-------------------
    sstateOk = true;
    chkSstateOk = true;
    nanDeriv = [];
    sing2 = false;
    if isstruct(Opt.sstate)
        % Call to the IRIS sstate solver.
        [This,sstateOk] = mysstatenonlin(This,Opt.sstate);
        if Opt.refresh && ~isempty(This.Refresh)
            This = refresh(This);
        end
    elseif isa(Opt.sstate,'function_handle')
        % Call to a user-supplied sstate solver.
        [This,sstateOk] = Opt.sstate(This);
        if Opt.refresh && ~isempty(This.Refresh)
            This = refresh(This);
        end
    end
    if isstruct(Opt.chksstate)
        [~,~,~,SstateErrorList] = mychksstate(This,Opt.chksstate);
        SstateErrorList = SstateErrorList{1};
        chkSstateOk = isempty(SstateErrorList);
    end
    if sstateOk && chkSstateOk && Opt.solve
        % Trigger fast solve by passing in only one input argument. This
        % does not compute expansion matrices.
        [This,nPath,nanDeriv,sing2] = mysolve(This,1,[],ExpMat);
    else
        nPath = 1;
    end
end

UpdateOk = nPath == 1 && sstateOk && chkSstateOk;

if ~ThrowErr
    return
elseif ~UpdateOk
    % Throw error and give access to the failed model object
    %--------------------------------------------------------
    model.failed(This,sstateOk,chkSstateOk,SstateErrorList, ...
        nPath,nanDeriv,sing2);
end

end