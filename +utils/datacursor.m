function Text = datacursor(~,Obj)
% datacursor  [Not a public function] Display data tips in graphs involving tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Text = {};
h = Obj.Target;

% Try to retrieve date line from the underlying plot.
dates = getappdata(h,'dateLine');
if ~isempty(dates)
    xdata = get(h,'XData');
    index = xdata == Obj.Position(1);
    if any(index)
        Text = [Text,{ ...
            sprintf('Date: %s',dat2char(dates(index))), ...
            }];
    end
end

% This more or less reproduces standard behaviour.
Text = [Text,{ ...
    sprintf('X: %g',Obj.Position(1)), ...
    sprintf('Y: %g',Obj.Position(2)), ...
    }];
if length(Obj.Position) > 2
    Text = [Text,{ ...
        sprintf('Z: %g',Obj.Position(3)), ...
        }];
end

end