function [Y,Rng,YNames,InpFmt,varargin] = myinpdata(This,varargin)
% myinpdata  [Not a public data] Input data and range including pre-sample for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ispanel(This) && isstruct(varargin{1})
    % Panel data.
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
    % Database.
    InpFmt = 'dbase';
    d = varargin{1};
    varargin(1) = [];
    if iscellstr(varargin{1})
        YNames = varargin{1};
        varargin(1) = [];
    elseif ischar(varargin{1})
        YNames = regexp(varargin{1},'\w+','match');
        varargin(1) = [];
    else
        YNames = This.Ynames;
    end
    Rng = varargin{1};
    varargin(1) = [];
    usrRng = Rng;
    [Y,~,Rng] = db2array(d,YNames,Rng);
    Y = permute(Y,[2,1,3]);
elseif istseries(varargin{1})
    % Time series.
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