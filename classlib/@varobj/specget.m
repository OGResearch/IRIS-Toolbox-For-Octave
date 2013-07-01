function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for varobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

nAlt = size(This.A,3);
realSmall = getrealsmall();

switch lower(Query)
    case {'omg','omega','cove','covresiduals'}
        X = This.Omega;
    case {'eig','eigval','roots'}
        X = This.eigval;
    case {'stableroots','explosiveroots','unstableroots','unitroots'}
        switch Query
            case 'stableroots'
                test = @(x) abs(x) < (1 - realSmall);
            case {'explosiveroots','unstableroots'}
                test = @(x) abs(x) > (1 + realSmall);
            case 'unitroots'
                test = @(x) abs(abs(x) - 1) <= realSmall;
        end
        X = nan(size(This.eigval));
        for ialt = 1 : nAlt
            inx = test(This.eigval(1,:,ialt));
            X(1,1:sum(inx),ialt) = This.eigval(1,inx,ialt);
        end
        inx = all(isnan(X),3);
        X(:,inx,:) = [];
    case {'nper','nobs'}
        X = permute(sum(This.fitted,2),[2,3,1]);
    case {'sample','fitted'}
        X = cell(1,nAlt);
        for ialt = 1 : nAlt
            X{ialt} = This.range(This.fitted(1,:,ialt));
        end
    case {'range'}
        X = This.range;
    case 'comment'
        % Bkw compatibility only; use comment(this) directly.
        X = comment(This);
    case {'ynames','ylist'}
        X = This.Ynames;
    case {'enames','elist'}
        X = This.Enames;
    case {'names','list'}
        X = [This.Ynames,This.Enames];
    case {'nalt'}
        X = nAlt;
    case {'groupnames','grouplist'}
        X = This.GroupNames;
    otherwise
        Flag = false;
end

end