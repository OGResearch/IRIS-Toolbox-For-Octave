function This = diff(This,Mode,Wrt)

nWrt = length(Wrt);
if nWrt == 0
    utils.error('sydney:diff', ...
        'Empty list of Wrt variables');
end

%--------------------------------------------------------------------------

if isequal(Mode,'enbloc')
    % Create one sydney that returns an array of derivatives.
    This = mydiff(This,Wrt);
    % Handle special case when there is no occurence of any of the `wrt`
    % variables in the expression, and a scalar zero is returned.
    if nWrt > 1 && isempty(This.func) && isequal(This.args,0)
        This.args = false(nWrt,1);
        This.lookahead = false;
    else
        if nWrt == 1
            This = reduce(This,1);
        else
            This = reduce(This);
        end
    end
elseif isequal(Mode,'separate')
    % Create cell array of sydneys.
    z = mydiff(This,Wrt);
    This = cell(1,nWrt);
    for i = 1 : nWrt
        This{i} = reduce(z,i);
    end
else
    utils.error('sydney:diff', ...
        'Invalid output mode.');
end

end