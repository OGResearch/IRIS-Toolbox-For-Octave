function [NamePtn,NameRplF,NameRplS] = mynamepattrepl(This)
% mynamepattrepl  [Not a public function] Patterns and replacements for
% names in equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(This.name);
flNameType = floor(This.nametype);

NamePtn = cell(1,nName);
NameRplF = cell(1,nName);
NameRplS = cell(1,nName);

%len = cellfun(@length,This.name);
%[~,inx] = sort(len,2,'descend');
offsetG = sum(flNameType < 5);

% Name patterns to search.
for i = 1 : nName
    NamePtn{i} = ['\<',This.name{i},'\>'];
    if flNameType(i) == 4
        % Replace parameter names including their possible time subscripts
        % and/or steady-state references. Parameter lags and leads are
        % simply ignored.
        NamePtn{i} = ['&?',NamePtn{i},'((\{[^\}]+\})?)'];
    end
end

% `%` ... variables, shocks, parameters
% `#` ... log variables in sstate equations.
% `@` ... time subscript
% `?` ... exogenous variables
% `!` ... name position

% Replacements in full equations.
for i = 1 : nName
    switch flNameType(i)
        case {1,2,3,4}
            % `%(:,@+15,!5)`.
            ic = sprintf('%g',i);
            repl = ['%(:,!',ic,',@)'];
        case 5 % Exogenous variables.
            % `?(!15,:)`.
            ic = sprintf('%g',i-offsetG);
            repl = ['?(!',ic,',:)'];
        otherwise
            utils.error('model:mynamepattrepl','#Internal');
    end
    NameRplF{i} = repl;
end

% Replacements in steady-state equations.
if ~This.IsLinear 
    for i = 1 : nName
        ic = sprintf('%g',i);
        switch flNameType(i)
            case {1,2} % Measurement and transition variables.
                % `%(!15)`.
                repl = ['%(!',ic,')'];
            case 3 % Shocks.
                repl = '0';
            case 4 % Parameters.
                % `%(!15)`.
                repl = ['%(!',ic,')'];
            case 5 % Exogenous variables.
                % `?(!15)`.
                ic = sprintf('%g',i-offsetG);
                repl = ['?(!',ic,')'];
            otherwise
                utils.error('model:mynamepattrepl','#Internal');
        end
        NameRplS{i} = repl;
    end
end

end
