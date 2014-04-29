function [This,Assigned] = assign(This,varargin)
% assign  [Not a public function] Assign values to names in modelobj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

persistent ASSIGNPOS ASSIGNRHS STDCORRPOS STDCORRRHS;

if isempty(varargin)
    return
end

level = false;
growth = false;
if ischar(varargin{1})
    if strcmp(varargin{1},'-level')
        level = true;
        varargin(1) = [];
    elseif strcmp(varargin{1},'-growth')
        growth = true;
        varargin(1) = [];
    end
end

% Number of input arguments with the growth label removed.
n = length(varargin);

nAlt = size(This.Assign,3);

% `Assign` and `stdcorr` are logical indices of values that have been
% assigned.
Assign = false(size(This.name));
stdcorr = false(size(This.stdcorr));

if isempty(varargin)
    if ismatlab
        doReset();
    else
        [ASSIGNPOS,ASSIGNRHS,STDCORRPOS,STDCORRRHS] = doReset4Oct();
    end
    Assigned = cell(1,0);
    return
    
elseif n == 1 && isa(varargin{1},'modelobj')
    % Assign from another model object. The names, name types, and number of
    % parameterisations must match.
    equalNames = isequal(This.name,varargin{1}.name);
    equalTypes = isequal(This.nametype,varargin{1}.nametype);
    equalAlter = size(This.Assign,3) == size(varargin{1}.Assign,3);
    if equalNames && equalAlter
        This.Assign = varargin{1}.Assign;
        This.stdcorr = varargin{1}.stdcorr;
        Assigned = Inf;
        return
    elseif ~equalNames || ~equalTypes
        utils.error('model', ...
            ['Cannot assign from a model object ', ...
            'with different names or name types.']);
    else
        utils.error('model', ...
            ['Cannot assign from a model object ', ...
            'with different number of paratemeterisations.']);
    end
    
elseif n == 1 && isnumeric(varargin{1})
    % m = assign(m,array).
    if isempty(ASSIGNPOS) && isempty(STDCORRPOS)
        utils.error('model', ...
            ['ASSIGN must be initiliased before used ', ...
            'with a single numeric input.']);
    end
    Assign(ASSIGNPOS) = true;
    stdcorr(STDCORRPOS) = true;
    This.Assign(1,ASSIGNPOS,:) = varargin{1}(ASSIGNRHS);
    This.stdcorr(1,STDCORRPOS,:) = varargin{1}(STDCORRRHS);
    if nargout == 1
        return
    end
    
elseif n <= 2 && iscellstr(varargin{1})
    % assign(m,cellstr) initialises quick-assign function.
    % m = assign(m,cellstr,array)
    list = varargin{1}(:).';
    varargin(1) = [];
    nList = length(list);
    [ASSIGNPOS,STDCORRPOS] = mynameposition(This,list);
    ASSIGNRHS = ~isnan(ASSIGNPOS);
    ASSIGNPOS = ASSIGNPOS(ASSIGNRHS);
    STDCORRRHS = ~isnan(STDCORRPOS);
    STDCORRPOS = STDCORRPOS(STDCORRRHS);
    
    if isempty(varargin)
        % Initialise quick-assign access and return.
        return
    end
    
    value = varargin{1};
    if size(value,2) == 1 && nList > 1
        value = value(1,ones(1,nList),:);
    end
    if size(value,3) == 1 && nAlt > 1
        value = value(1,:,ones(1,nAlt));
    end
    if (growth || level) && any(imag(value(:)) ~= 0)
        utils.error('model', ...
            ['You may only assign real numbers ', ...
            'when using the ''-level'' or ''-growth'' options.']);
    end
    if growth
        value(1,ASSIGNRHS,:) = real(This.Assign(1,ASSIGNPOS,:)) ...
            + 1i*value(1,ASSIGNRHS,:);
    elseif level
        value(1,ASSIGNRHS,:) = value(1,ASSIGNRHS,:) ...
            + 1i*imag(This.Assign(1,ASSIGNPOS,:));
    end
    if any(ASSIGNRHS)
        Assign(ASSIGNPOS) = true;
        This.Assign(1,ASSIGNPOS,:) = value(1,ASSIGNRHS,:);
    end
    if any(STDCORRRHS)
        stdcorr(STDCORRPOS) = true;
        This.stdcorr(1,STDCORRPOS,:) = value(1,STDCORRRHS,:);
    end
    if ismatlab
        doReset();
    else
        [ASSIGNPOS,ASSIGNRHS,STDCORRPOS,STDCORRRHS] = doReset4Oct();
    end
    
elseif n <= 2 && isstruct(varargin{1})
    % m = assign(m,struct), or
    % m = assign(m,struct,clone).
    d = varargin{1};
    varargin(1) = [];
    c = fieldnames(d);
    cc = c;
    if ~isempty(varargin) && ~isempty(varargin{1})
        clone = varargin{1};
        if ~preparser.mychkclonestring(clone)
            utils.error('preparser', ...
                'Invalid clone string: ''%s''.', ...
                clone);
        end
        cc = strrep(clone,'?',c);
    end
    [assignPos,stdcorrPos] = mynameposition(This,cc);
    for i = find(~isnan(assignPos))
        x = d.(c{i});
        if (growth || level) && any(imag(x(:)) ~= 0)
            utils.error('model', ...
                ['You may only assign real numbers ', ...
                'when using the ''level'' or ''growth'' labels.']);
        end
        if growth
            x = real(This.Assign(1,assignPos(i),:)) + 1i*x;
        elseif level
            x = x + 1i*imag(This.Assign(1,assignPos(i),:));
        end
        This.Assign(1,assignPos(i),:) = x;
        Assign(assignPos(i)) = true;
    end
    for i = find(~isnan(stdcorrPos))
        This.stdcorr(1,stdcorrPos(i),:) = d.(c{i});
        stdcorr(stdcorrPos(i)) = true;
    end
    if ismatlab
        doReset();
    else
        [ASSIGNPOS,ASSIGNRHS,STDCORRPOS,STDCORRRHS] = doReset4Oct();
    end
    if nargout == 1
        return
    end
    
elseif iscellstr(varargin(1:2:end))
    % m = assign(m,name,value,name,value,...)
    Assign = false(1,size(This.Assign,2));
    stdcorr = false(1,size(This.stdcorr,2));
    for j = 1 : 2 : length(varargin)
        if isempty(varargin{j})
            continue
        end
        % Allow for equal signs in `assign(m,'alpha=',1)`.
        varargin{j} = strtrim(varargin{j});
        if ~isempty(varargin{j}) && varargin{j}(end) == '='
            varargin{j}(end) = '';
        end
        [assignInx,stdcorrInx] = mynameposition(This,varargin{j});
        for i = find(assignInx).'
            if (growth || level) && any(imag(varargin{j+1}(:)) ~= 0)
                utils.error('model', ...
                    ['You may only assign real numbers ', ...
                    'when using the ''level'' or ''growth'' labels.']);
            end
            if growth
                varargin{j+1} = real(This.Assign(1,i,:)) + 1i*varargin{j+1};
            elseif level
                varargin{j+1} = varargin{j+1} + 1i*imag(This.Assign(1,i,:));
            end
            This.Assign(1,i,:) = varargin{j+1};
            Assign(i) = true;
        end
        if any(stdcorrInx)
            This.stdcorr(1,stdcorrInx,:) = varargin{j+1};
            stdcorr(stdcorrInx) = true;
        end
    end
    if ismatlab
        doReset();
    else
        [ASSIGNPOS,ASSIGNRHS,STDCORRPOS,STDCORRRHS] = doReset4Oct();
    end
    
else
    % Throw an invalid assignment error.
    utils.error(class(This), ...
        'Invalid assignment to a %s object.', ...
        class(This));
end


% Put together list of parameters, steady states, std deviations, and
% correlations that have been assigned.
if nargout > 1
    Assigned = This.name(Assign);
    ne = sum(This.nametype == 3);
    eList = This.name(This.nametype == 3);
    Assigned = [Assigned, ...
        regexprep(eList(stdcorr(1:ne)),'^.','std_$0','once')];
    pos = find(tril(ones(ne),-1) == 1);
    temp = zeros(ne);
    temp(pos(stdcorr(ne+1:end))) = 1;
    [i,j] = find(temp == 1);
    for k = 1 : length(i)
        Assigned{end+1} = ['corr_',eList{i(k)},'_',eList{j(k)}]; %#ok<AGROW>
    end
end

% Nested functions.

%**************************************************************************
    function doReset()
        ASSIGNPOS = [];
        ASSIGNRHS = [];
        STDCORRPOS = [];
        STDCORRRHS = [];
    end
    
    function [ASSIGNPOS,ASSIGNRHS,STDCORRPOS,STDCORRRHS] = doReset4Oct()
        ASSIGNPOS = [];
        ASSIGNRHS = [];
        STDCORRPOS = [];
        STDCORRRHS = [];
    end

end
