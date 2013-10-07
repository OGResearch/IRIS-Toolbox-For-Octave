function [MAXT,MINT,INVALID,varargout] = evaltimesubs(varargin)
% evaltimesubs [Not a public function] Parse equations within an equation block.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

varargout = varargin;
MAXT = 0;
MINT = 0;
INVALID = {};

replacefunc = @xxevaltimesubs; %#ok<NASGU>
for i = 1 : length(varargout)
    varargout{i} = ...
        regexprep(varargout{i},'\{([^\}\{;]*)\}','${replacefunc($1)}');
end

% Nested functions.

    function C = xxevaltimesubs(C)
        if strcmp(C,'0')
            C = '';
            return
        end
        tmp = sscanf(C,'%g');
        if length(tmp) == 1 && isnumeric(tmp) && ~isnan(tmp)
            tmp = round(tmp);
            if tmp == 0
                C = '';
            else
                C = sprintf('{%+g}',tmp);
                MAXT = max([MAXT,tmp]);
                MINT = min([MINT,tmp]);
            end
            return
        end
        % If `sscanf` fails, try eval.
        tmp = xxprotectedeval(C);
        if length(tmp) == 1 && isnumeric(tmp) && ~isnan(tmp)
            tmp = round(tmp);
            if tmp == 0
                C = '';
            else
                C = sprintf('{%+g}',tmp);
                MAXT = max([MAXT,tmp]);
                MINT = min([MINT,tmp]);
            end
            return
        end
        INVALID{end+1} = ['{',C,'}'];
        C = '';
    end

end

% Subfunctions.

%**************************************************************************
function PROTECTEDARG = xxprotectedeval(PROTECTEDARG)
try
    t = 0; %#ok<NASGU>
    PROTECTEDARG = eval([PROTECTEDARG,';']);
catch %#ok<CTCH>
    PROTECTEDARG = NaN;
end
end