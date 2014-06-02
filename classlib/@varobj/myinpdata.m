function [Y,Rng,YNames,InpFmt,varargin] = myinpdata(This,varargin)
% myinpdata  [Not a public data] Input data and range including pre-sample for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------
    
if isstruct(varargin{1})
    
    % Database for plain VAR
    %------------------------
    InpFmt = 'dbase';
    d = varargin{1};
    varargin(1) = [];
    
    if iscellstr(varargin{1}) || ischar(varargin{1})
        % ##### Nov 2013 OBSOLETE and scheduled for removal.
        YNames = varargin{1};
        if ischar(YNames)
            YNames = regexp(YNames,'\w+','match');
        end
        varargin(1) = [];
        
        if ~isempty(This.YNames)
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
            This.YNames = YNames;
            This = myenames(This,[]);
        end
    end
    YNames = This.YNames;
    
    Rng = varargin{1};
    varargin(1) = [];
    usrRng = Rng;
    [Y,~,Rng] = db2array(d,This.YNames,Rng);
    Y = permute(Y,[2,1,3]);
    
elseif is.tseries(varargin{1})
    
    % Time series for plain VAR
    %---------------------------
    
    % ##### Nov 2013 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Using tseries objects as input data is obsolete ', ...
        'and will be removed from a future version of IRIS. ', ...
        'Enter input data in databases (struct) instead.']);
    
    InpFmt = 'tseries';
    Y = varargin{1};
    Rng = varargin{2};
    usrRng = Rng;
    varargin(1:2) = [];
    [Y,Rng] = rangedata(Y,Rng);
    Y = permute(Y,[2,1,3]);
    YNames = This.YNames;
    
else
    
    % Invalid
    %---------
    utils.error('varobj:myinpdata','Invalid format of input data.');

end

if isequal(usrRng,Inf)
    sample = ~any(any(isnan(Y),3),1);
    first = find(sample,1);
    last = find(sample,1,'last');
    Y = Y(:,first:last,:);
    Rng = Rng(first:last);
end

end