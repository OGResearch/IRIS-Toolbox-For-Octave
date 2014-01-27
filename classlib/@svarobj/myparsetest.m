function [H,IsY] = myparsetest(this,c)
% myparsetest  [Not a public function] Determine the latest shock reponse
% period referenced to in a test string for Householder SVARs, and check
% for the presence of asymptotic cumulative reponses.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(this.A,1);

occur = {};
for i = regexp(c,'\<S\>\(','start')
    close = strfun.matchbrk(c,i+1);
    if ~isempty(close)
        occur{end+1} = c(i:close); %#ok<AGROW>
    end
end

S = zeros(ny,ny,0);
for j = 1 : length(occur)
    eval([occur{j},'=1;']);
end
H =  size(S,3);

% Check for the presence of references to the asymptotic cumulative
% response matrix `Y`.
IsY = ~isempty(regexp(c,'\<Y\>\(','once'));

end