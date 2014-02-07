function export(This)
% export  Save carry-around files on the disk.
%
% Syntax
% =======
%
%     export(M)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose carry-around m-files (written in
% underlying the model file) will be saved on the disk.
%
% Description
% ============
%
% See the IRIS model language keyword [`!export`](modellang/export) for
% help on how to write carry-around m-files in model files.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

preparser.export(This,This.Export);

end