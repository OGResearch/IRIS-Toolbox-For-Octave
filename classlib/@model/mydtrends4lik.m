function [D,X] = mydtrends4lik(This,TTrend,PInx,G,IAlt)
% mydtrends4lik  [Not a public function] Return dtrends coefficient matrices for likelihood functions.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

isX = nargout > 1;
nPOut = numel(PInx);
nPer = numel(TTrend);
nName = length(This.name);
ny = sum(This.nametype == 1);

% Return the matrix of deterministic trends, `D`, and the impact
% matrix for out-of-likelihood parameters, `X`.
D = zeros(ny,nPer);
X = zeros(ny,nPOut,nPer);

% Get the requested parameterisation.
x = This.Assign(1,:,min(end,IAlt));

% Reset out-of-likelihood parameters to zero.
if nPOut > 0
    x(1,PInx,:) = 0;
end

occur = This.occur(This.eqtntype == 3,(This.tzero-1)*nName+(1:nName));
eqtnF = This.eqtnF(This.eqtntype == 3);
dEqtnF = This.deqtnF(This.eqtntype == 3);

for i = 1 : ny
    % Evaluate the deterministic trends with out-of-lik parameters zero.
    D(i,:) = eqtnF{i}(x,1,TTrend,G);
    if isX && ~isempty(PInx)
        parametersInThisDTrend = find(occur(i,:));
        for j = 1 : nPOut
            inx = parametersInThisDTrend == PInx(j);
            if any(inx)
                % Evaluate derivatives of dtrends equation w.r.t.
                % out-of-likelihood parameters. size of d is nocc-by-nper.
                if isempty(dEqtnF{i}) || isempty(dEqtnF{i}{inx})  ...
                        || ~isa(dEqtnF{i}{inx},'function_handle')
                    utils.error('model', ....
                        ['This model object has been loaded from a disk file ', ...
                        'created in an older version of IRIS, and is not ', ...
                        'compatible. You must re-create the model object from ', ...
                        'from the original model file.']);
                end
                X(i,j,:) = dEqtnF{i}{inx}(x,1,TTrend,G);
            end
        end
    end
end

end