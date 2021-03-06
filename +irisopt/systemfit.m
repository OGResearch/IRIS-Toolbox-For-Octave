function def = systemfit()
% systemfit  [Not a public function] Default options for systemfit class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

def = struct();

def.chkinputdata = { ...
    'dates','numeric',@(x) isequal(x,'numeric') || isequal(x,'char'), ...
    };

def.evalident = { ...
    };

def.filter = { ...
    };

def.kalman = { ...
    'exclude',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x), ...
    'objrange',Inf,@isnumeric, ...
    'outoflik',[],@isempty, ...
    'relative',true,@islogicalscalar, ...
    'transform',[],@(x) isempty(x) || isstruct(x), ...
    'vary',[],@(x) isempty(x) || isstruct(x), ...
    };

def.systemfit = { ...
    'std',0,@(x) isnumericscalar(x) && x >= 0, ...
    };

end