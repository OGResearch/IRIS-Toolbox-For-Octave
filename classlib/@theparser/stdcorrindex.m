function [StdcorrIx,ShkIx1,ShkIx2] = stdcorrindex(ListE,Name)
% stdcorrindex  [Not a public function] Logical index for a single stdcorr name.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% The output argument `StdcorrIx` is a 1-by-N logical index with N =
% ne*(ne-1)/2 with true for each correlation name matched in char `Name`.
% `Name` can be a plain string or a regular expression.

%--------------------------------------------------------------------------

ne = length(ListE);
nStdcorr = ne*(ne-1)/2;

StdcorrIx = false(1,nStdcorr);
ShkIx1 = false(1,nStdcorr);
ShkIx2 = false(1,nStdcorr);

if length(Name) >= 5 && strncmp(Name,'std_',4)
    
    % Position of a std deviation.
    
    stdList = regexprep(ListE,'.*','std_$0');
    StdcorrIx(1:ne) = strfun.strcmporregexp(stdList,Name);
    ShkIx1 = StdcorrIx;
    
elseif length(Name) >= 9 && strncmp(Name,'corr_',5)
    
    % Position of a corr coefficient.
    
    % Break down the corr name corr_SHOCK1__SHOCK2 into SHOCK1 and SHOCK2.
    shkNames = regexp(Name(6:end),'^(.*?)__([^_].*)$','tokens','once');
    
    if isempty(shkNames) ...
            || isempty(shkNames{1}) || isempty(shkNames{2})
        return
    end
    
    % Try to find the positions of the shock names.
    ShkIx1 = strfun.strcmporregexp(ListE,shkNames{1});
    ShkIx2 = strfun.strcmporregexp(ListE,shkNames{2});
    
    % Place the shocks in the cross-correlation matrix.
    corrMat = false(ne);
    corrMat(ShkIx1,ShkIx2) = true;
    corrMat(ShkIx2,ShkIx1) = true;
    corrMat = tril(corrMat,-1);
    
    % Back out the position in the stdcorr vector.
    [i,j] = find(corrMat);
    for k = 1 : length(i)
        p = ne + sum((ne-1):-1:(ne-j(k)+1)) + (i(k)-j(k));
        StdcorrIx(p) = true;
    end
    
end

end