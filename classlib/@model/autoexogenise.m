function varargout = autoexogenise(This,varargin)
% autoexogenise  Get or set variable/shock pairs for use in autoexogenised simulation plans.
%
% Syntax fo getting autoexogenised variable/shock pairs
% ======================================================
%
%     A = autoexogenise(M)
%
% Syntax fo setting autoexogenised variable/shock pairs
% ======================================================
%
%     M = autoexogenise(M,A)
%
% Input arugments
% ================
%
% * `M` [ model ] - Model object.
%
% * `A` [ struct | empty ] - Database with each field representing a
% variable/shock pair, A.Variable_Name = 'Shock_Name', that can be used in
% building [simulation plans](plan/Contents) by the plan function
% [`autoexogenise`](plan/autoexogenise).
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with updated definitions of autoexogenised
% variable/shock pairs.
%
% Description
% ============
%
% Whenever you set the autoexogenised variable/shock pairs, the previously
% assigned pairs are removed, and replaced with the new ones in `A`. In
% other words, the new pairs are not added to the existing ones, the
% replace them.
%
% Example 
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    varargout{1} = doGetAutoExogenise();
else
    doSetAutoExogenise();
    varargout{1} = This;
end

% Nested functions.

%**************************************************************************
    function A = doGetAutoExogenise()
        inx = ~isnan(This.Autoexogenise);
        if any(inx)
            xylist = This.name(inx);
            elist = This.name(This.Autoexogenise(inx));
            A = cell2struct(elist,xylist,2);
        else
            A = struct();
        end
    end % doGetAutoexogenise().

%**************************************************************************
    function doSetAutoExogenise()
        xyList = fieldnames(varargin{1});
        eList = struct2cell(varargin{1});
        % `This.Autoexogenise` is reset to NaNs within `myautoexogenise`.
        [This,invalid,nonUnique] = myautoexogenise(This,xyList,eList);
        if any(invalid)
            utils.error('model', ...
                'Cannot autoexogenise the following name: ''%s''.', ...
                xyList{invalid});
        end
        if ~isempty(nonUnique)
            utils.error('model', ...
                ['This shock is included in more than one ', ...
                'autoexogenise definitions: ''%s''.'], ...
                nonUnique{:});
        end
    end % doSetAutoExogenise().

end