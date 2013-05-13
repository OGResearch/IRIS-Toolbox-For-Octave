function Sub = mycopyobj(This,Sub)
% mycopyobj  [Not a public function] Copy model properties to a subclass object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

list = utils.ndprop('model');
for i = 1 : length(list)
    Sub.(list{i}) = This.(list{i});
end

end