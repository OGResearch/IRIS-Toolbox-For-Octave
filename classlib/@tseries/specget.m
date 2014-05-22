function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

switch Query
    
    case {'range','first2last','start2end','first:last','start:end'}
        X = range(This);
    
    case {'min','minrange','nanrange'}
        sample = all(~isnan(This.data(:,:)),2);
        X = range(This);
        X = X(sample);
    
    case {'start','startdate','first'}
        X = This.start;
    
    case {'nanstart','nanstartdate','nanfirst','allstart','allstartdate'}
        sample = all(~isnan(This.data(:,:)),2);
        if isempty(sample)
            X = NaN;
        else
            X = This.start + find(sample,1,'first') - 1;
        end
        
    case {'end','enddate','last'}
        X = This.start + size(This.data,1) - 1;
    
    case {'nanend','nanenddate','nanlast','allend','allenddate'}
        sample = all(~isnan(This.data(:,:)),2);
        if isempty(sample)
            X = NaN;
        else
            X = This.start + find(sample,1,'last') - 1;
        end
        
    case {'freq','frequency','per','periodicity'}
        X = datfreq(This.start);
    
    case {'data','value','values'}
        % Not documented. Use x.data directly.
        X = This.data;
    
    case {'comment','comments'}
        % Not documented. User x.Comment directly.
        X = comment(This);
    
    otherwise
        Flag = false;
end

end