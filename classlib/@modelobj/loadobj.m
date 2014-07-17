function This = loadobj(This)
% loadobj  [Not a public function] Prepare modelobj for use in workspace and handle bkw compatibility.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Create empty aliases for names if missing.
try
    if isempty(This.namealias)
        This.namealias = cell(size(This.name));
        This.namealias(:) = {''};
    end
catch
    This.namealias = cell(size(This.name));
    This.namealias(:) = {''};
end


% Create empty aliases for equatios if missing.
try
    if isempty(This.eqtnalias)
        This.eqtnalias = cell(size(This.eqtn));
        This.eqtnalias(:) = {''};
    end
catch
    This.eqtnalias = cell(size(This.eqtn));
    This.eqtnalias(:) = {''};
end


% Handle carry-around functions.
try %#ok<TRYNC>
    if iscell(This.Export)
        Export = struct('FName',{},'Content',{});
        for i = 1 : 2 : length(This.Export)
            Export(end+1).FName = This.Export{i}; %#ok<AGROW>
            Export(end).Content = This.Export{i+1};
        end
        This.Export = Export;
    elseif isstruct(This.Export)
        if isfield(This.Export,'filename')
            This.Export.FName = This.Export.filename;
            This.Export = rmfield(This.Export,'filename');
        end
        if isfield(This.Export,'content')
            This.Export.Content = This.Export.content;
            This.Export = rmfield(This.Export,'content');
        end
    end
end


% Signs of log-linearized variables.
try
    if isempty(This.IxLog)
        This.IxLog = This.log;
    end
catch
    This.IxLog = This.log;
end


% Create and save carry-around files.
try %#ok<TRYNC>
    export(This);
end


try %#ok<TRYNC>
    This.IsLinear = This.linear;
end


end
