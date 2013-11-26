function C = sprintf(This,varargin)
% sprintf  [Not a public function] Print model object to text.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = '';

pos = find(This.nametype == 1);
C = [C,xxPrintNames(This,'!measurement_variables',pos)];

pos = find(This.nametype == 2);
C = [C,xxPrintNames(This,'!transition_variables',pos)];

pos = find(This.nametype == 3);
[mshocks,tshocks] = myshocktypes(This);
C = [C,xxPrintNames(This,'!measurement_shocks',pos(mshocks),false)];
C = [C,xxPrintNames(This,'!transition_shocks',pos(tshocks),false)];

pos = find(This.nametype == 4);
C = [C,xxPrintNames(This,'!parameters',pos)];

pos = find(This.log);
C = [C,xxPrintNames(This,'!log_variables',pos,false)];

pos = find(This.eqtntype == 1);
C = [C,xxPrintEqtns(This,'!measurement_equations',pos)];

pos = find(This.eqtntype == 2);
C = [C,xxPrintEqtns(This,'!transition_equations',pos)];

end

% Subfunctions.

%**************************************************************************
function C = xxPrintNames(This,Heading,Pos,IsValue)
    
try
    IsValue; %#ok<VUNUS>
catch %#ok<CTCH>
    IsValue = true;
end

if isempty(Pos)
    C = '';
    return
end

br = sprintf('\n');
tab = sprintf('\t');

C = [br,Heading,br];

for i = Pos
    C = [C,tab,This.name{i}]; %#ok<AGROW>
    if IsValue && ~isnan(This.Assign(i))
        assignreal = real(This.Assign(i));
        assignimag = imag(This.Assign(i));
        C = [C,sprintf('=%.16f',assignreal)]; %#ok<AGROW>
        if assignimag ~= 0
            C = [C,sprintf('%+.16fi',assignimag)]; %#ok<AGROW>
        end
    end
    C = [C,br]; %#ok<AGROW>
end

end % xxPrintNames().

%**************************************************************************
function C = xxPrintEqtns(This,Heading,Pos)

if isempty(Pos)
    C = '';
    return
end

br = sprintf('\n');
tab = sprintf('\t');

C = [br,Heading,br];

for i = Pos
    eqtn = This.eqtn{i};
    eqtn = strrep(eqtn,'=',' = ');
    eqtn = strrep(eqtn,'= #',' =# ');
    eqtn = strrep(eqtn,'!!',[' ...',br,tab,tab,'!! ']);
    C = [C,tab,eqtn]; %#ok<AGROW>
    C = [C,br,br];
end

end % xxPrintEqtns().