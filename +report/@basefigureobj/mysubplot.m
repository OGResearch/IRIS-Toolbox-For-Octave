function Sub = mysubplot(This)
% mysubplot  [Not a public function] Compute subdivision of the figure window.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if strcmp(This.options.subplot,'auto')
    nChild = length(This.children);
    candidate = ceil(sqrt(nChild));
    if candidate*(candidate-1) >= nChild
        Sub = {candidate,candidate-1};
    else
        Sub = {candidate,candidate};
    end
else
    Sub = {This.options.subplot(1),This.options.subplot(2)};
end

end
