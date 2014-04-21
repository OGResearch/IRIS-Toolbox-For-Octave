function Opt = mysolveopt(This,Mode,Opt)
% mysstateopt  [Not a public function] Prepare steady-state solver options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(Opt,false)
    return
end

if isequal(Opt,true)
    Opt = struct();
end

Opt = passvalopt('model.solve',Opt);

if isequal(Mode,'silent')
    Opt.fast = true;
    Opt.progress = false;
    Opt.warning = false;
end

if ischar(Opt.linear) && strcmpi(Opt.linear,'auto')
    Opt.linear = This.linear;
elseif Opt.linear ~= This.linear
    Opt.select = false;
end

end
