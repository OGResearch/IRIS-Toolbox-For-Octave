function D = hdatafinal(Y,This,Range)
% hdatafinal  [Not a public function] Finalise output struct.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

D = struct();

if isfield(Y,'predmean') && ~isequal(Y.predmean,[])
    doOneOutputArea('pred');
end

if isfield(Y,'filtermean') && ~isequal(Y.filtermean,[])
    doOneOutputArea('filter');
end

if isfield(Y,'smoothmean') && ~isequal(Y.smoothmean,[])
    doOneOutputArea('smooth');
end

f = fieldnames(D);
if length(f) == 1
    D = D.(f{1});
end

% Nested functions.

%**************************************************************************
    function doOneOutputArea(Name)
        D.(Name) = struct();
        meanField = [Name,'mean'];
        stdField = [Name,'std'];
        contField = [Name,'cont'];
        mseField = [Name,'mse'];
        if isfield(Y,stdField) || isfield(Y,contField) ...
                || isfield(Y,mseField)
            D.(Name).mean = hdata2tseries(Y.(meanField),This,Range);
            if isfield(Y,stdField)
                D.(Name).std = hdata2tseries(Y.(stdField),This,Range);
            end
            if isfield(Y,contField)
                D.(Name).cont = hdata2tseries(Y.(contField),This,Range);
            end
            if isfield(Y,mseField)
                Y.(mseField) = permute(Y.(mseField),[3,1,2,4]);
                D.(Name).mse = tseries();
                D.(Name).mse.start = Range(1);
                D.(Name).mse.data = Y.(mseField);
                D.(Name).mse.Comment = cell(1, ...
                    size(Y.(mseField),2), ...
                    size(Y.(mseField),3), ...
                    size(Y.(mseField),4));
                D.(Name).mse.Comment(:) = {''};
                D.(Name).mse = mytrim(D.(Name).mse);
            end
        else
            D.(Name) = hdata2tseries(Y.(meanField),This,Range);
        end
    end % doOneOutputArea().

end