function mychksyntax(This)
% mychksyntax  [Not a public function] Check equations for syntax errors.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(This.name);
t0 = find(This.Shift == 0);
nt = length(This.Shift);
ne = sum(This.nametype == 3);

% Finalize sstate equations.
isGrowth = false;
eqtnS = myfinaleqtns(This,isGrowth);

x = rand(1,nName,nt);
dx = zeros(1,nName,nt);
L = x;
ttrend = 0;
g = zeros(sum(This.nametype == 5),1);

% Create a random vector `x` for dynamic links. In dynamic links, we allow
% std and corr names to occurs, and append them to the assign vector.
std = double(This.IsLinear)*1 + double(~This.IsLinear)*log(1.01);
if any(This.eqtntype == 4)
    xs = [rand(1,nName,1),std*ones(1,ne),zeros(1,ne*(ne-1)/2)];
end

isLink = This.eqtntype == 4;

% Full dynamic equations except links.
inx = ~isLink;
try
    e = mosw.str2func(['@(x,dx,L,t,ttrend,g) [',This.eqtnF{inx},']']);
    feval(e,x,dx,L,t0,ttrend,g);
catch
    doLookUp('f',inx);
end

% Steady-state equations.
if ~This.IsLinear
    inx = ~isLink;
    try
        e = mosw.str2func(['@(x,dx,L,t,ttrend,g) [',eqtnS{inx},']']);
        feval(e,x,dx,L,t0,ttrend,g);
    catch
        doLookUp('s',inx);
    end
end

% Links.
inx = isLink;
try
    e = mosw.str2func(['@(x,dx,L,t,ttrend,g) [',This.eqtnF{inx},']']);
    feval(e,x,dx,L,t0,ttrend,g);
catch
    doLookUp('f',inx);
end


% Nested functions...


%**************************************************************************


    function doLookUp(Type,Inx)
        errUndeclared = {};
        errSyntax = {};
        
        for iiEq = find(Inx)
            
            if Type == 'f'
                e = This.eqtnF{iiEq};
            else
                e = eqtnS{iiEq};
            end
            
            if isempty(e)
                continue
            end
            
            try
                e = strfun.vectorise(e);
                e = mosw.str2func(['@(x,dx,L,t,ttrend,g)',e]);
                
                if This.eqtntype(iiEq) < 4
                    feval(e,x,dx,L,t0,ttrend,g);
                else
                    % Evaluate RHS of dynamic links. They can refer to std or corr names, so we
                    % have to use the `x1` vector.
                    e(xs,[],[],1,[],g);
                end
                
                if This.IsLinear ...
                        || This.eqtntype(iiEq) > 2 ...
                        || isempty(eqtnS{iiEq})
                    continue
                end
                
                e = eqtnS{iiEq};
                e = mosw.str2func(['@(x,dx,L,t,ttrend,g)',e]);
                feval(e,x,dx,L,t0,ttrend,g);               
            catch E
                % Undeclared names should have been already caught. But a few exceptions
                % may still exist.
                [match,tokens] = ...
                    regexp(E.message,'Undefined function or variable ''(\w*)''', ...
                    'match','tokens','once');

                if ~isempty(match)
                    errUndeclared{end+1} = tokens{1}; %#ok<AGROW>
                    errUndeclared{end+1} = This.eqtn{iiEq}; %#ok<AGROW>
                else
                    message = E.message;
                    errSyntax{end+1} = This.eqtn{iiEq}; %#ok<AGROW>
                    if ~isempty(message) && message(end) ~= '.'
                        message(end+1) = '.'; %#ok<AGROW>
                    end
                    errSyntax{end+1} = message; %#ok<AGROW>
                end
            end
            
        end
        
        if ~isempty(errUndeclared)
            utils.error('model',[utils.errorparsing(This), ...
                'Undeclared or mistyped name ''%s'' in ''%s''.'], ...
                errUndeclared{:});
        end
        
        if ~isempty(errSyntax)
            utils.error('model',[utils.errorparsing(This), ...
                'Syntax error in ''%s''.\n', ...
                '\tUncle says: %s'], ...
                errSyntax{:});
        end
    end % doLookUp().


end
