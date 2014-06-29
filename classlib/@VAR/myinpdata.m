function [Y,X,Rng,YNames,InpFmt,varargin] = myinpdata(This,D,Rng,varargin)% myinpdata  [Not a public data] Input data and range including pre-sample for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('V',@is.VAR);
pp.addRequired('D',@isstruct);
pp.addRequired('Range',@isnumeric)
try
    pp.parse(This,D,Rng);
catch
    % ##### Nov 2013 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['This syntax for estimating VAR objects is obsolete ', ...
        'and will be removed from a future version of IRIS. ', ...
        'Specify variable names at the time of creating ', ...
        'the VAR object, and supply an input database and range ', ...
        'when estimating it instead See help on VAR/VAR and VAR/estimate.'], ...
        class(This));
    [Y,Rng,YNames,InpFmt,varargin] = ...
        myinpdata@varobj(This,D,Rng,varargin{:});
    X = zeros(0,size(Y,2),size(Y,3));
    Y = {Y};
    X = {X};
    return
end

%--------------------------------------------------------------------------

ny = length(This.YNames);
nx = length(This.XNames);
Rng = Rng(:).';
nGrp = max(1,length(This.GroupNames));
Y = cell(1,nGrp);
X = cell(1,nGrp);
YNames = This.YNames;
YXNames = [This.YNames,This.XNames];

sw = struct();
sw.LogSign = [];
sw.BaseYear = get(This,'baseYear');

if isempty(This.GroupNames)
    
    % Input database for plain VARs
    %-------------------------------
    InpFmt = 'dbase';
    usrRng = Rng;
    [yx,~,Rng] = db2array(D,YXNames,Rng,sw);
    if isempty(yx)
        yx = nan(0,ny+nx);
    end
    yx = permute(yx,[2,1,3]);
    Y{1} = yx(1:ny,:,:);
    X{1} = yx(ny+(1:nx),:,:);
    doClipRange();

else
    
    % Input database for panel VARs
    %-------------------------------
    InpFmt = 'panel';
    if any(isinf(Rng(:)))
        utils.error('varobj:myinpdata', ...
            'Cannot use Inf for input range in panel estimation.');
    end
    % Check if all group names are contained withing the input database.
    doChkGroupNames();
    for iGrp = 1 : nGrp
        name = This.GroupNames{iGrp};
        yx = db2array(D.(name),YXNames,Rng,sw);
        yx = permute(yx,[2,1,3]);
        Y{iGrp} = yx(1:ny,:,:);
        X{iGrp} = yx(ny+(1:nx),:,:);
    end
        
end


% Nested function...


%**************************************************************************


    function doChkGroupNames()
        found = true(1,nGrp);
        for iiGrp = 1 : nGrp
            if ~isfield(D,This.GroupNames{iiGrp})
                found(iiGrp) = false;
            end
        end
        if any(~found)
            utils.error('VAR', ...
                'This group is not contained in the input database: ''%s''.', ...
                This.GroupNames{~found});
        end
    end % doChkGroupNames()


%**************************************************************************


    function doClipRange()
        % Do not use `X` to determine the start and end of the range because this
        % could result in unncessary clipping of lags of the endogenous variables.
        if isinf(usrRng(1))
            sample = ~any(any(isnan(Y{1}),3),1);
            first = find(sample,1);
            Y{1} = Y{1}(:,first:end,:);
            X{1} = X{1}(:,first:end,:);
            Rng = Rng(first:end);
        end
        if isinf(usrRng(end))
            sample = ~any(any(isnan(Y{1}),3),1);
            last = find(sample,1,'last');
            Y{1} = Y{1}(:,1:last,:);
            X{1} = X{1}(:,1:last,:);
            Rng = Rng(1:last);
        end
    end % doClipRange()


end
