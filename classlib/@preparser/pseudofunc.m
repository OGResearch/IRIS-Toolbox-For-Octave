function [C,Invalid] = pseudofunc(C)
% pseudofunc  [Not a public function] Expand pseudofunctions in preparser.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

list = {'diff','dot','movsum','movprod','movavg','difflog'};
list = sprintf('\\<%s\\>|',list{:});
list(end) = '';

Invalid = {};
while true
    [start,finish,match] = ...
        regexp(C,['(',list,')(?=\()'],'start','end','match','once');
    if ~isempty(start)
        % Position of the opening bracket.
        open = finish + 1;
        % Find the matching closing bracket.
        [close,inside] = strfun.matchbrk(C,open);
        inside = strrep(inside,' ','');
        if ~isempty(inside)
            switch match
                case 'diff'
                    replace = xxDiffOrDot(inside,'-');
                case 'dot'
                    replace = xxDiffOrDot(inside,'*');
                case 'difflog'
                    replace = xxDiffLog(inside);
                case 'movsum'
                    replace = xxMovSumOrMovProd(inside,'+');
                case 'movprod'
                    replace = xxMovSumOrMovProd(inside,'*');
                case 'movavg'
                    replace = xxMovAvg(inside);
            end
        else
            replace = '';
            close = finish;
        end
        if isempty(replace)
            % Report invalid pseudofunction.
            Invalid{end+1} = C(start:end); %#ok<AGROW>
        else
            % Wrap the result of the pseudofunction in brackets.
            replace = ['(',replace,')']; %#ok<AGROW>
        end
        C = [C(1:start-1),replace,C(close+1:end)];
    else
        break
    end
end

end % pseudofunc()


% Subfunctions.


%**************************************************************************


function [Exprn,Shift] = xxParseFunc(C,DefaultShift)
% xxparsefunc  Parse pseudofunctions.
%     pseudofunc(expression)
%     pseudofunc(expression,k)

Shift = DefaultShift;
tokens = regexp(C,'^(.*?)((,[\+\-]?\d+)?)$','tokens','once');
if isempty(tokens) || isempty(tokens{1})
    Exprn = '';
    return
end
Exprn = tokens{1};
if ~isempty(tokens{2})
    tokens{2}(1) = '';
    try
        Shift = eval(tokens{2});
    catch %#ok<CTCH>
        Exprn = '';
        return
    end
end

end % xxParseFunc()


%**************************************************************************


function [C,K] = xxDiffOrDot(C,Op)

[C,K] = xxParseFunc(C,-1);
if ~isempty(C)
    C = ['(',C,')',Op,'(',xxShift(C,K),')'];
end

end % xxDiffOrDot()


%**************************************************************************


function [C,K] = xxDiffLog(C)

[C,K] = xxParseFunc(C,-1);
if ~isempty(C)
    C = ['log(',C,')-log(',xxShift(C,K),')'];
end

end % xxDiffLog()


%**************************************************************************


function [C,K] = xxMovSumOrMovProd(C,Op)

[exprn,K] = xxParseFunc(C,-4);
if ~isempty(C)
    if K > 0
        shiftVec = 1 : K-1;
    else
        K = -K;
        shiftVec = -(1 : K-1);
    end
    C = ['(',exprn,')'];
    for i = shiftVec
        C = [C,Op,'(',xxShift(exprn,i),')']; %#ok<AGROW>
    end
end

end % xxMovSumOrMovProd()


%**************************************************************************


function C = xxMovAvg(C)

[C,shift] = xxMovSumOrMovProd(C,'+');
C = sprintf('(%s)/%g',C,abs(shift));

end % xxMovAvg()


%**************************************************************************


function C = xxShift(C,K)

ptn = '(\<[A-Za-z]\w*\>)((\{[\+\-]?\d+\})?)(?!\()';
if is.matlab % ##### MOSW
    replaceFunc = @doOneShift; %#ok<NASGU>
    C = regexprep(C,ptn,'${replaceFunc($1,$2)}');
else
    C = octfun.dregexprep(C,ptn,'doOneShift',[1,2]); %#ok<UNRCH>
end


    function X = doOneShift(Name,Shift)
        if isempty(Shift)
            Shift = sprintf('{%g}',K);
        else
            Shift = sscanf(Shift,'{%g}');
            if ~isnumeric(Shift) || length(Shift) ~= 1
                Shift = '{NaN}';
            else
                Shift = sprintf('{%g}',Shift+K);
            end
        end
        X = [Name,Shift];
    end % doOneShift()


end % xxShift()
