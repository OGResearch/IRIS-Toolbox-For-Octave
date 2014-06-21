function C = dregexprep(C,Pattern,ReplFunc,InpTokens,varargin)
% dregexprep  [Not a public function] Regexprep with dynamic expressions,
% version for Octave.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if is.matlab()
    
    % Matlab
    %--------
    error('iris:octfun', 'This function must not be used in Matlab!');
else
    
    % Octave
    %--------
    isChar = ischar(C);
    if isChar
        C = {C};
    elseif ~iscellstr(C)
        C = NaN;
        return
    end
    inx = strcmpi(varargin,'once');
    isOnce = any(inx);
    varargin(inx) = [];
    for i = 1 : length(C)
        from = 1;
        while true
            [start,finish,match,tokens] = ...
                regexp(C{i}(from:end),Pattern, ...
                'once','start','end','match','tokens', ...
                varargin{:});
            if isempty(start)
                break
            end
            args = {};
            if ~isempty(InpTokens)
                tokens = regexprep(tokens,'((?<!''))['']((?!''))','$1''''$2');
                args = [{match},tokens(:)'];
                args = args(InpTokens+1);
            end
            args = sprintf('''%s'',',args{:});
            replString = evalin('caller',sprintf('%s(%s)', ...
                ReplFunc,args(1:end-1)));
            start = from + start - 1;
            finish = from + finish - 1;
            C{i} = [C{i}(1:start-1),replString,C{i}(finish+1:end)];
            if isOnce
                break
            end
            from = start + length(replString);
        end
    end
    if isChar
        C = C{1};
    end
end

end