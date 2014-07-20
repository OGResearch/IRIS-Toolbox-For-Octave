function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for plan objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

switch Query
    case {'exogenised','exogenized','onlyexogenised','onlyexogenized'}
        isOnly = strncmp(Query,'only',4);
        X = struct();
        templ = tseries();
        for i = 1 : length(This.XList)
            if isOnly && ~any(This.XAnch(i,:))
                continue
            end
            X.(This.XList{i}) = replace(templ,+This.XAnch(i,:).', ...
                This.Start, ...
                [This.XList{i},' Exogenised points']);
        end
    case {'endogenised','endogenized','onlyendogenised','onlyendogenized'}
        isOnly = strncmp(Query,'only',4);
        X = struct();
        templ = tseries();
        for i = 1 : length(This.NList)
            if isOnly ...
                    && ~any(This.NAnchReal(i,:)) ...
                    && ~any(This.NAnchImag(i,:))
                continue
            end
            X.(This.NList{i}) = replace(templ, ...
                +This.NAnchReal(i,:).' + 1i*(+This.NAnchImag(i,:).'), ...
                This.Start, ...
                [This.NList{i},' Endogenised points']);
        end
    case 'range'
        X = This.Start : This.End;
        
    case {'start','startdate'}
        X = This.Start;
        
    case {'end','enddate'}
        X = This.End;
        
    otherwise
        Flag = false;
end

end
