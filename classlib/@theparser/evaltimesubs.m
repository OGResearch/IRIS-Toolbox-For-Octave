function [Eqtn,MaxT,MinT,ValidSubs] = evaltimesubs(This,UsrEqtn) %#ok<INUSL>
% evaltimesubs  [Not a public function] Validate and evaluate time subscripts.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nEqtn = length(UsrEqtn);
MaxT = 0;
MinT = 0;
ValidSubs = true(1,nEqtn);

Eqtn = UsrEqtn;

Eqtn = strrep(Eqtn,'{t+','{+');
Eqtn = strrep(Eqtn,'{t-','{-');
Eqtn = strrep(Eqtn,'{0}','');
Eqtn = strrep(Eqtn,'{-0}','');
Eqtn = strrep(Eqtn,'{+0}','');
Eqtn = strrep(Eqtn,'{1','{+1');
Eqtn = strrep(Eqtn,'{2','{+2');
Eqtn = strrep(Eqtn,'{3','{+3');
Eqtn = strrep(Eqtn,'{4','{+4');
Eqtn = strrep(Eqtn,'{5','{+5');
Eqtn = strrep(Eqtn,'{6','{+6');
Eqtn = strrep(Eqtn,'{7','{+7');
Eqtn = strrep(Eqtn,'{8','{+8');
Eqtn = strrep(Eqtn,'{9','{+9');

% Replace standard time subscripts {+XX}, {-XX} with {@+XX}, {@-XX}.
Eqtn = regexprep(Eqtn,'\{([+\-]\d+)\}','{@$1}');

% Find non-standard time subscripts, try to evaluate them and replace with
% a standard string.
ptn = '\{[^@].*?\}';
s = regexp([Eqtn{:}],ptn,'once');
if ~isempty(s)
    for iEq = 1 : nEqtn
        % ##### MOSW:
        % replaceFunc = @doNonstandardTimeSubs; %#ok<NASGU>
        % Eqtn{iEq} = regexprep(Eqtn{iEq},ptn,'${replaceFunc($0)}');
        Eqtn{iEq} = mosw.dregexprep(Eqtn{iEq},ptn, ...
            @doNonstandardTimeSubs,0);
    end
    if any(~ValidSubs)
        return
    end
end

c = regexp(Eqtn,'\{@[+\-]\d+\}','match');
c = [c{:}]; % Expand individual equations.
% nc = length(c); % Total number of time subscripts found.
c = [c{:}]; % Expand matches into one string.
if ~isempty(c)
    x = sscanf(c,'{@%g}');
    x = x(:).';
    MaxT = max([MaxT,x]);
    MinT = min([MinT,x]);
end
    

    function C = doNonstandardTimeSubs(C0)
        C = '';
        try %#ok<TRYNC>
            c = C0(2:end-1); % Strip out the enclosing curly braces.
            xx = xxProtectedEval(c); % Use protected eval to avoid conflict with workspace.
            if is.numericscalar(xx) && xx == round(xx)
                if round(xx) == 0
                    C = '';
                    return
                else
                    MaxT = max([MaxT,xx]);
                    MinT = min([MinT,xx]);
                    C = sprintf('{@%+g}',round(xx));
                    return
                end
            end
        end
        ValidSubs(iEq) = false;
    end % doNonstandardTimeSubs()


end %% xxEvalTimeSubs()


%**************************************************************************
function varargout = xxProtectedEval(varargin)
varargout{1} = eval(varargin{1});
end % xxProtectedEval()