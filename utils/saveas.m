function saveas(FileName,varargin)
% saveas  Save variables to a mat file under different names.
%
% Syntax
% =======
%
%     saveas(FileName,'NewName1=',Var1,'NewName2=',Var2,...)
%
% Input arguments
% ================
%
% * `FilName` [ char ] - Name of the input MAT file (saved previously using
% the `save` command).
%
% * `'NewName1'`, `'NewName2'`, ... [ char ] - New names for the variables
% under which they will save to the MAT file; in MAT files
% with just one single variable stored in them, the name can be omitted.
%
% * `Var1`, `Var2` [ * ] - variables saved to the MAT file.
%
% Description
% ============
%
% Example
% ========
%
% Create two variables, `a` and `b`, and save them under new names, `A5`
% and `B10`, to a mat file named `'myfile.mat'`. Loading the mat file will
% create the variables under their new names.
%
%     a = rand(5);
%     b = rand(10);
%     saveas('myfile.mat','A5=',a,'B10=',b);
%     clear;
%     load('myfile.mat');
%     whos
%
%     Name       Size            Bytes  Class     Attributes
% 
%     A5         5x5               200  double              
%     B10       10x10              800  double   
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

x = matfile(FileName);

% Loop over input names, and assign the mat file variable to the
% corresponding output argument.
for i = 1 : 2 : numel(varargin)
    newName = regexp(varargin{i},'\w+','once','match');
    if ~ischar(newName) || ~isvarname(newName)
        utils.error('io', ...
            'This is not a valid variable name: ''%s''.', ...
            newName);
    end
    x.(newName) =  varargin{i+1};
end

end