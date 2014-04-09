function [StdcorrInx,ShkInx1,ShkInx2] = mystdcorrindex(This,Name)
% mystdcorrindex  [Not a public function] Index of names of std deviations and cross-correlations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% `This` can be either a `modelobj` object or a list of shock names.
%
% `Index` is a 1-by-N logical index with N = ne*(ne-1)/2 with true for each
% correlation name matched in char `Name`. `Name` can be a plain string or
% a regular expression.

if isa(This,'modelobj')
    nStdcorr = size(This.stdcorr,2);
    eList = This.name(This.nametype == 3);
    ne = length(eList);
elseif iscellstr(This)
    eList = This;
    ne = length(eList);
    nStdcorr = ne*(ne-1)/2;
else
    utils.error('modelobj','Invalid type(s) of input argument(s).');
end

%--------------------------------------------------------------------------

StdcorrInx = false(1,nStdcorr);
ShkInx1 = false(1,nStdcorr);
ShkInx2 = false(1,nStdcorr);

if length(Name) >= 5 && strncmp(Name,'std_',4)
    
    % Position of a std deviation.
    if ismatlab
        stdList = regexprep(eList,'.*','std_$0');
    else
        stdList = myregexprep(eList,'.*','${[''std_'' $0]}');
    end
    StdcorrInx(1:ne) = strfun.strcmporregexp(stdList,Name);
    ShkInx1 = StdcorrInx;
    ShkInx2 = nan(size(ShkInx1));
    
elseif length(Name) >= 9 && strncmp(Name,'corr_',5)
    
    % Position of a corr coefficient.
    
    % Break down the corr name corr_SHOCK1__SHOCK2 into SHOCK1 and SHOCK2.
    shkNames = regexp(Name(6:end),'^(.*?)__([^_].*)$','tokens','once');
    
    if isempty(shkNames) ...
            || isempty(shkNames{1}) || isempty(shkNames{2})
        return
    end
    
    % Try to find the positions of the shock names.
    ShkInx1 = strfun.strcmporregexp(eList,shkNames{1});
    ShkInx2 = strfun.strcmporregexp(eList,shkNames{2});
    
    % Place the shocks in the cross-correlation matrix.
    corrMat = false(ne);
    corrMat(ShkInx1,ShkInx2) = true;
    corrMat(ShkInx2,ShkInx1) = true;
    corrMat = tril(corrMat,-1);
    
    % Back out the position in the stdcorr vector.
    [i,j] = find(corrMat);
    for k = 1 : length(i)
        p = ne + sum((ne-1):-1:(ne-j(k)+1)) + (i(k)-j(k));
        StdcorrInx(p) = true;
    end
    
end

end