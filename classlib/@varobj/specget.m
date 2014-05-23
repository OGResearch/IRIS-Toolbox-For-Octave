function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

nAlt = size(This.A,3);
realSmall = getrealsmall();

switch lower(Query)
    
    case {'omg','omega','cove','covresiduals'}
        X = This.Omega;
        
    case {'eig','eigval','roots'}
        X = This.EigVal;
        
    case {'stableroots','explosiveroots','unstableroots','unitroots'}
        switch Query
            case 'stableroots'
                test = @(x) abs(x) < (1 - realSmall);
            case {'explosiveroots','unstableroots'}
                test = @(x) abs(x) > (1 + realSmall);
            case 'unitroots'
                test = @(x) abs(abs(x) - 1) <= realSmall;
        end
        X = nan(size(This.EigVal));
        for ialt = 1 : nAlt
            inx = test(This.EigVal(1,:,ialt));
            X(1,1:sum(inx),ialt) = This.EigVal(1,inx,ialt);
        end
        inx = all(isnan(X),3);
        X(:,inx,:) = [];
        
    case {'nper','nobs'}
        X = permute(sum(This.Fitted,2),[2,3,1]);
        
    case {'sample','fitted'}
        X = cell(1,nAlt);
        for ialt = 1 : nAlt
            X{ialt} = This.Range(This.Fitted(1,:,ialt));
        end
        
    case {'range'}
        X = This.Range;
        
    case 'comment'
        % Bkw compatibility only; use comment(this) directly.
        X = comment(This);
        
    case {'ynames','ylist'}
        X = This.YNames;
        
    case {'enames','elist'}
        X = This.ENames;
        
    case {'gnames','glist'}
        X = This.GNames;
        
    case {'names','list'}
        X = [This.YNames,This.ENames,This.GNames];
        
        
    case {'nalt'}
        X = nAlt;
        
    case {'groupnames','grouplist'}
        X = This.GroupNames;
        
    otherwise
        Flag = false;
        
end

end