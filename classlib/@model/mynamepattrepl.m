function [NamePatt,NameReplF,NameReplS] = mynamepattrepl(This)
% mynamepattrepl  [Not a public function] Patterns and replacements for
% names in equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(This.name);

NamePatt = cell(1,nName);
NameReplF = cell(1,nName);
NameReplS = cell(1,nName);

len = cellfun(@length,This.name);
[~,inx] = sort(len,2,'descend');
goffset = sum(This.nametype < 5);

% Name patterns to search.
for i = inx
    NamePatt{i} = ['\<',This.name{i},'\>'];
end

% % ... variables, shocks, parameters
% @ ... time subscript
% ? ... exogenous variables
% ! ... variable id

% Replacements in full equations.
for i = inx
    switch This.nametype(i)
        case {1,2,3,4}
            % %(:,@15,!).
            ic = sprintf('%g',i);
            repl = ['%(:,!',ic,',@)'];
        otherwise
            % ?(@15,:).
            ic = sprintf('%g',i-goffset);
            repl = ['?(!',ic,'%g,:)'];
    end
    NameReplF{i} = repl;
end

% Replacements in steady-state equations.
if ~This.linear 
    for i = inx
        ic = sprintf('%g',i);
        switch This.nametype(i)
            case {1,2} % Measurement and transition variables.
                % (%(@15)) or exp(%(@15)).
                repl = ['(%(!',ic,'))'];
                if This.log(i)
                    repl = ['exp',repl]; %#ok<AGROW>
                end
            case 3 % Shocks.
                repl = '0';
            case 4 % Parameters.
                % %(@15).
                repl = ['%(!',ic,')'];
            case 5 % Exogenous variables.
                repl = 'NaN';
        end
        NameReplS{i} = repl;
    end
end

end