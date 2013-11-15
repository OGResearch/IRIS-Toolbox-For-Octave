function [Y,Rng,YNames,InpFmt,varargin] = myinpdata(This,varargin)
% myinpdata  [Not a public data] Input data and range including pre-sample for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ispanel(This) && isstruct(varargin{1})

    % Database for panel VAR
    %------------------------
    InpFmt = 'panel';
    d = varargin{1};
    varargin(1) = [];
    Rng = varargin{1};
    varargin(1) = [];
    YNames = This.Ynames;
    if any(isinf(Rng(:)))
        utils.error('varobj', ...
            'Cannot use Inf for input range in panel estimation.');
    end
    usrRng = Rng;
    nGrp = length(This.GroupNames);
    Y = cell(1,nGrp);
    % Check if all group names are contained withing the input database.
    doChkGroupNames();
    for iGrp = 1 : nGrp        
        name = This.GroupNames{iGrp};        
        iY = db2array(d.(name),YNames,Rng);
        iY = permute(iY,[2,1,3]);
        Y{iGrp} = iY;
    end
    
elseif isstruct(varargin{1})
    
    % Database for plain VAR
    %------------------------
    InpFmt = 'dbase';
    d = varargin{1};
    varargin(1) = [];
    
    isObsolete = false;
    if iscellstr(varargin{1}) || ischar(varargin{1})
        % ##### Nov 2013 OBSOLETE and scheduled for removal.
        isObsolete = true;
        YNames = varargin{1};
        if ischar(YNames)
            YNames = regexp(YNames,'\w+','match');
        end
        varargin(1) = [];
    else
        YNames = This.Ynames;
    end
    
    if isObsolete
        if ~isempty(This.Ynames)
            utils.error('varobj:myinpdata', ...
                'Variable names already specified in the %s object.', ...
                class(This));
        else
            utils.warning('obsolete', ...
                ['This syntax for specifying variable names is obsolete ', ...
                'and will be removed from a future version of IRIS. ', ...
                'Specify variable names at the time of creating ', ...
                '%s objects instead.'], ...
                class(This));
            This.Ynames = YNames;
            This = myenames(This,[]);
        end
    end
    
    Rng = varargin{1};
    varargin(1) = [];
    usrRng = Rng;
    [Y,~,Rng] = db2array(d,YNames,Rng);
    Y = permute(Y,[2,1,3]);
    
elseif istseries(varargin{1})
    
    % Time series for plain VAR
    %---------------------------
    InpFmt = 'tseries';
    Y = varargin{1};
    Rng = varargin{2};
    usrRng = Rng;
    varargin(1:2) = [];
    [Y,Rng] = rangedata(Y,Rng);
    Y = permute(Y,[2,1,3]);
    YNames = This.Ynames;
    
else
    
    % Invalid.
    utils.error('varobj','Invalid format of input data.');

end

if isequal(usrRng,Inf)
    sample = ~any(any(isnan(Y),3),1);
    first = find(sample,1);
    last = find(sample,1,'last');
    Y = Y(:,first:last,:);
    Rng = Rng(first:last);
end

% Nested function.

%**************************************************************************
    function doChkGroupNames()
        found = true(1,nGrp);
        for iiGrp = 1 : nGrp
            if ~isfield(d,This.GroupNames{iiGrp})
                found(iiGrp) = false;
            end
        end
        if any(~found)
            utils.error('VAR', ...
                'This group is not contained in the input database: ''%s''.', ...
                This.GroupNames{~found});
        end
    end % doChkGroupNames().

end