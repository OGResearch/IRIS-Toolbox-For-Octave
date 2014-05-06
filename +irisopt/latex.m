function Def = latex()
% latex  [Not a public function] Default options for latex package functions.
%
% Backend IRIS function.
% No help provided.

% The IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.epstopdf = {...
    'display',false,@islogical,...
    'enlargebox',10,@(x) isnumeric(x) ...
    && (length(x) == 1 || length(x) == 4), ...
    };

Def.compilepdf = { ...
    'cd',false,@is.logicalscalar, ...
    'display',true,@is.logicalscalar, ...
    'echo',false,@is.logicalscalar, ...
    'maxrerun',5,@is.numericscalar, ...
    'minrerun',1,@is.numericscalar, ...
    };

Def.publish = { ...
    'author','',@ischar, ...
    'cleanup',true,@is.logicalscalar, ...
    'closeall',true,@is.logicalscalar, ...
    'date','\today',@ischar, ...
    'deletetempfiles,cleanup',[],@(x) isempty(x) || is.logicalscalar(x), ...
    'display',true,@is.logicalscalar, ...
    'evalcode',true,@is.logicalscalar, ...
    'event','',@ischar, ...
    'figurescale',is.hg2(0.75,1),@(x) is.numericscalar(x) && x > 0, ...
    'figurewidth','4in',@ischar, ...
    'irisversion',true,@is.logicalscalar, ...
    'linespread','auto',@(x) (ischar(x) && strcmpi(x,'auto')) ...
    || is.numericscalar(x) && x > 0, ...
    'matlabversion',true,@is.logicalscalar, ...
    'numbered',true,@is.logicalscalar, ...
    'papersize','letterpaper', ...
    @(x) isequal(x,'a4paper') || isequal(x,'letterpaper'), ...
    'preamble','',@ischar, ...
    'package',{},@(x) iscellstr(x) || ischar(x) || isempty(x), ...
    'template','paper',@(x) ischar(x) && any(strcmpi(x,{'paper','present'})), ...
    'textscale',0.70,@is.numericscalar, ...
    'toc',true,@is.logicalscalar, ...
    'usenewfigure',false,@is.logicalscalar, ...
    };

end