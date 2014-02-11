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
        for i = 1 : length(This.xList)
            if isOnly && ~any(This.xAnchors(i,:))
                continue
            end
            X.(This.xList{i}) = replace(templ,+This.xAnchors(i,:).', ...
                This.startDate, ...
                [This.xList{i},' Exogenised points']);
        end
    case {'endogenised','endogenized','onlyendogenised','onlyendogenized'}
        isOnly = strncmp(Query,'only',4);
        X = struct();
        templ = tseries();
        for i = 1 : length(This.nList)
            if isOnly ...
                    && ~any(This.nAnchorsReal(i,:)) ...
                    && ~any(This.nAnchorsImag(i,:))
                continue
            end
            X.(This.nList{i}) = replace(templ, ...
                +This.nAnchorsReal(i,:).' + 1i*(+This.nAnchorsImag(i,:).'), ...
                This.startDate, ...
                [This.nList{i},' Endogenised points']);
        end
    case 'range'
        X = This.startDate : This.endDate;
        
    case {'start','startdate'}
        X = This.startDate;
        
    case {'end','enddate'}
        X = This.endDate;
        
    otherwise
        Flag = false;
end

end
