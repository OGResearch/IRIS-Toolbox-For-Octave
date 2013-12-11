function Ans = myget(This,Query)
% myget  [Not a public function] Protected get method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

switch lower(Query)
    
    case 'canbeexogenised'
        Ans = This.name(This.nametype <= 2);
        
    case 'canbeendogenised'
        Ans = This.name(This.nametype == 3);
        
    case 'canbenonlinearised'
        if any(This.nonlin)
            label = This.eqtnlabel;
            empty = cellfun(@isempty,label);
            label(empty) = This.eqtn(empty);
            Ans = label(This.nonlin);
        else
            Ans = {};
        end

end

end