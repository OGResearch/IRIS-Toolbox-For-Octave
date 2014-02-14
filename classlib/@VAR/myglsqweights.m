function W = myglsqweights(This,Opt)
% myglsqweights  [Not a public function] Vector of period weights for PVAR estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

range = This.range;
nXPer = length(This.range);
p = Opt.order;

if ispanel(This)
    nGrp = length(This.GroupNames);
else
    nGrp = 1;
end

isTimeWeights = ~isempty(Opt.timeweights) && isa(Opt.timeweights,'tseries');
isGrpWeights = ~isempty(Opt.groupweights);

if ~isTimeWeights && ~isGrpWeights
    W = [];
    return
end

% Time weights.
if isTimeWeights
    Wt = Opt.timeweights(range,:);
    Wt = Wt(:).';
    Wt = repmat(Wt,1,nGrp);
else
    Wt = ones(1,nXPer);
end

% Group weights.
if isGrpWeights
    Wg = Opt.groupweights(:).';
    doChkGrpweights();
else
    Wg = ones(1,nGrp);
end

% Total weights.
W = [];
for iGrp = 1 : nGrp
    W = [W,Wt*Wg(iGrp),nan(1,p)]; %#ok<AGROW>
end
W(W == 0) = NaN;
if all(isnan(W(:)))
    W = [];
end
   
% Nested functions.

%**************************************************************************
    function doChkGrpweights()
        if length(Wg) ~= nGrp
            utils.error('PVAR', ...
                ['The length of the vector of group weights (%g) must ', ...
                'match the number of groups in the PVAR object (%g).'], ...
                length(Wg),nGrp);
        end
    end % doChkGrpWeights().

end