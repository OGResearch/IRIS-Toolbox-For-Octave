function Stack = getstack()
% getstack  [Not a public function] Get the stack of callers with IRIS functions excluded.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Stack = dbstack('-completenames');

% Get the IRIS root directory name.
[ans,irisFolder] = fileparts(irisget('irisroot')); %#ok<NOANS,ASGLU>
irisFolder = lower(irisFolder);

while ~isempty(Stack) ...
        && ~isempty(strfind(lower(Stack(1).file),irisFolder))
    Stack(1) = [];
end

end