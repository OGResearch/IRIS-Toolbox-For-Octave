% !export  Create a carry-around file to be saved on the disk.
%
% Syntax
% =======
%
%     !export(FILENAME)
%         FILE_CONTENTS
%     !end
%
% Description
% ============
%
% You can include in the model file the contents of files you need or want
% to carry around together with the model; a typical example is your own
% m-file functions used in the model equations.
%
% The file or files are created and save under the name specified in the
% `!export` keyword at the time you load the model using the function
% [`model`](model/model). The contents of the export files is are also
% stored in the model objects. You can manually re-create and re-save the
% files by running the function [`export`](model/export).
%
% Note that if no filename is provided or `FILENAME` is empty, the
% corresponding `!export` block is discarded without an error or warning.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
