function F__ = str2func(S__)
% str2func  [Not a public function] Workaround for Octave's str2func.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if true % ##### MOSW
    F__ = str2func(S__);
else
    if S__(1) ~= '@' %#ok<UNRCH>
        S__ = ['@',S__];
    end
    F__ = eval(S__);
end

end
