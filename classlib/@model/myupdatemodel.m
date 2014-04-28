function [This,UpdateOk] = myupdatemodel(This,P,Pri,Opt,IsError)
% myupdatemodel  [Not a public function] Update parameters, sstate, solve, and refresh.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% `IsError`: Throw error if update fails.
try
    IsError; %#ok<VUNUS>
catch %#ok<CTCH>
    IsError = true;
end

%--------------------------------------------------------------------------

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
    if ~isequal(Opt.solve,false)
        [This,nPth,nanDerv,sing2] = mysolve(This,1,Opt.solve);
    else
        nPth = 1;
    end
    if isstruct(Opt.sstate)
        This = mysstatelinear(This);
        if Opt.refresh && ~isempty(This.Refresh)
            This = refresh(This);
        end
    end
    sstateOk = true;
    chkSstateOk = true;
	sstateErrList = {};
else
    % Non-linear models
    %-------------------
    sstateOk = true;
    sstateErrList = {};
    chkSstateOk = true;
    nanDerv = [];
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
    elseif iscell(Opt.sstate) && isa(Opt.sstate{1},'function_handle')
        % Call to a user-supplied sstate solver with extra arguments.
        [This,sstateOk] = feval(Opt.sstate{1},This,Opt.sstate{2:end});
        if Opt.refresh && ~isempty(This.Refresh)
            This = refresh(This);
        end        
    end
    % Run chksstate only if steady state has been recomputed.
    if ~isequal(Opt.sstate,false) && isstruct(Opt.chksstate)
        [~,~,~,sstateErrList] = mychksstate(This,Opt.chksstate);
        sstateErrList = sstateErrList{1};
        chkSstateOk = isempty(sstateErrList);
    end
    if sstateOk && chkSstateOk && ~isequal(Opt.solve,false)
        [This,nPth,nanDerv,sing2] = mysolve(This,1,Opt.solve);
    else
        nPth = 1;
    end
end

UpdateOk = nPth == 1 && sstateOk && chkSstateOk;

if ~IsError
    return
elseif ~UpdateOk
    % Throw error and give access to the failed model object
    %--------------------------------------------------------
    model.failed(This,sstateOk,chkSstateOk,sstateErrList, ...
        nPth,nanDerv,sing2);
end

end