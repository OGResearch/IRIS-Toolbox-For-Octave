function [This,S] = assign(This,S)
% assign  [Not a public function] Evaluate in-file values and add them to assign database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

asgn = This.Assign;

% Evaluate values assigned in the model code and/or in the `assign`
% database. Go backward to evaluate parameters first so that they are
% available for steady-state expressions.

    function C = doReplaceNameValue(C)
        if any(strcmpi(C,{'Inf','Nan'}))
            return
        end
        C = ['asgn.',C];
    end % doReplaceNameValue()

ptn = '\<[A-Za-z]\w*\>(?![\(\.])';
if ismatlab
    rplFunc = @doReplaceNameValue; %#ok<NASGU>
end
stdcorrDecld = {};

for iBlk = blkpos(This,This.assignBlkOrd)
    
    if isempty(S(iBlk).name)
        continue
    end
    
    for iName = 1 : length(S(iBlk).name)
        name = S(iBlk).name{iName};
        if isfield(asgn,name)
            continue
        end
        
        value = S(iBlk).namevalue{iName};
        if isempty(value)
            continue
        end
        if is.matlab % ##### MOSW
            value = regexprep(value,ptn,'${rplFunc($0)}');
        else
            value = octfun.dregexprep(value,ptn,'doReplaceNameValue',0); %#ok<UNRCH>
        end
        
        try
            x = eval(value);
            if isnumeric(x) % is.numericscalar(x)
                asgn.(name) = x(:).';
            end
        catch %#ok<CTCH>
            asgn.(name) = NaN;
        end
    end
    
    % Remove the declared `std_` and `corr_` names from the list of names
    % after values in the model file have been assigned.
    stdInx = strncmp(S(iBlk).name,'std_',4);
    corrInx = strncmp(S(iBlk).name,'corr_',5);
    inx = stdInx | corrInx;
    stdcorrDecld = [stdcorrDecld,S(iBlk).name(inx)]; %#ok<AGROW>
    if any(inx)
        S(iBlk).name(inx) = [];
        S(iBlk).nametype(inx) = [];
        S(iBlk).namelabel(inx) = [];
        S(iBlk).namealias(inx) = [];
        S(iBlk).nameflag(inx) = [];
    end
    
end

% Check if declared stdcorr names are valid.
if ~isempty(stdcorrDecld)
    nStdcorrDecld = length(stdcorrDecld);
    valid = true(size(stdcorrDecld));
    listE = [S(This.stdcorrBasis).name];
    for i = 1 : nStdcorrDecld
        stdcorr = stdcorrDecld{i};
        inx = theparser.stdcorrindex(listE,stdcorr);
        valid(i) = any(inx);
    end
    if any(~valid)
                utils.error('theparser:assign',[utils.errorparsing(This), ...
                    'This is not a valid std_ or corr_ name: ''%s''.'], ...
                    stdcorrDecld{~valid});
    end
end

This.Assign = asgn;

end