function D = array2db(X,RANGE,LIST,ISLOG,D)
% array2db  Convert numeric array to database.
%
% Syntax
% =======
%
%     D = array2db(X,RANGE,LIST)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Numeric array with individual time series organised
% row-wise.
%
% * `RANGE` [ numeric ] - Date range for the columns in `X`.
%
% * `LIST` [ cellstr | char ] - List of names for the time series in
% individual rows of `X`.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

try
    ISLOG; 
catch 
    ISLOG = false(1,size(X,1));
end

try
    D;
catch
    D = struct();
end

if ischar(LIST)
    LIST = regexp(LIST,'\w+','match');
end

if ~isnumeric(X) || ~isnumeric(RANGE) ...
        || (~islogical(ISLOG) && ~isstruct(ISLOG)) || ~isstruct(D)
    error('Incorrect type of input argument(s).');
end

% TODO: Allow for unsorted dates.

%**************************************************************************

RANGE = RANGE(1) : RANGE(end);
nx = size(X,1);
nalt = size(X,3);
nper = length(RANGE);

template = tseries(RANGE,zeros(nper,nalt));
for i = 1 : nx
    Xi = permute(X(i,:,:),[2,3,1]);
    if (islogical(ISLOG) && ISLOG(i)) ...
            || (isstruct(ISLOG) && ISLOG.(LIST{i}))
        Xi = exp(Xi);
    end
    D.(LIST{i}) = replace(template,Xi);
end

end