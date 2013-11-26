function [AssignInx,StdcorrInx,ShkInx1,ShkInx2] ...
    = mynameindex(Name,EList,String)
% mynameindex  [Not a public function] Index of a name in the Assign or stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(Name);
ne = length(EList);
nStdcorr = ne*(ne-1)/2;
AssignInx = false(1,nName);
StdcorrInx = false(1,nStdcorr);
ShkInx1 = false(1,ne);
ShkInx2 = false(1,ne);

if (length(String) >= 5 && strncmp(String,'std_',4)) ...
    || (length(String) >= 9 && strncmp(String,'corr_',5))
    % Index of a std or corr name in the stdcorr vector.
    [StdcorrInx,ShkInx1,ShkInx2] = modelobj.mystdcorrindex(EList,String);
else
    % Index of a parameter or steady-state name in the Assign vector.
    AssignInx = strfun.strcmporregexp(Name,String);
end

end