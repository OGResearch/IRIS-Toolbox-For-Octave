function [X,NotFound,Invalid] = data4eval(This,Inp,Dates)

nName = length(This.name);
X = cell(1,nName);
found = true(1,nName);
valid = true(1,nName);

% Assign data
%-------------
for id = find(This.nameType == 1)
    X{id} = [];
    name = This.name{id};
    found(id) = isfield(Inp,name);
    if ~found(id)
        continue
    end
    x = Inp.(name);
    if isa(x,'tseries')
        X{id} = x(Dates,:);
    else
        X{id} = x;
    end
end

% Assign parameters
%-------------------
for ip = find(This.nameType == 2)
    X{ip} = NaN;
    name = This.name{ip};
    found(ip) = isfield(Inp,name);
    if ~found(ip)
        continue
    end
    x = Inp.(name);
    valid(ip) = isnumericscalar(x);
    if ~valid(ip)
        continue
    end
    X{ip} = x;
end

NotFound = This.name(~found);
Invalid = This.name(~valid);

end