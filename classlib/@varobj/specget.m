function [Ans,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Ans = [];
Flag = true;

nAlt = size(This.A,3);
realSmall = getrealsmall();

switch lower(Query)
    
    case {'omg','omega','cove','covresiduals'}
        Ans = This.Omega;
        
    case {'eig','eigval','roots'}
        Ans = This.EigVal;
        
    case {'stableroots','explosiveroots','unstableroots','unitroots'}
        switch Query
            case 'stableroots'
                test = @(x) abs(x) < (1 - realSmall);
            case {'explosiveroots','unstableroots'}
                test = @(x) abs(x) > (1 + realSmall);
            case 'unitroots'
                test = @(x) abs(abs(x) - 1) <= realSmall;
        end
        Ans = nan(size(This.EigVal));
        for ialt = 1 : nAlt
            inx = test(This.EigVal(1,:,ialt));
            Ans(1,1:sum(inx),ialt) = This.EigVal(1,inx,ialt);
        end
        inx = all(isnan(Ans),3);
        Ans(:,inx,:) = [];
        
    case {'nper','nobs'}
        Ans = permute(sum(This.Fitted,2),[2,3,1]);
        
    case {'sample','fitted'}
        Ans = cell(1,nAlt);
        for ialt = 1 : nAlt
            Ans{ialt} = This.Range(This.Fitted(1,:,ialt));
        end
        
    case {'range'}
        Ans = This.Range;
        
    case 'comment'
        % Bkw compatibility only; use comment(this) directly.
        Ans = comment(This);
        
    case {'ynames','ylist'}
        Ans = This.YNames;
        
    case {'enames','elist'}
        Ans = This.ENames;
        
    case {'xnames','xlist'}
        Ans = This.XNames;
        
    case {'names','list'}
        Ans = [This.YNames,This.ENames,This.XNames];
        
    case {'nalt'}
        Ans = nAlt;
        
    case {'baseyear'}
        Ans = This.BaseYear;
        
    case {'groupnames','grouplist'}
        Ans = This.GroupNames;
        
    otherwise
        Flag = false;
        
end

end