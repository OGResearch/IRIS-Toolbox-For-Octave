function C = speclatexcode(This)
% speclatexcode  [Not a public function] Produce LaTeX code for figure object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = '';

% Create a figure window, and update the property `This.handle`.
This = myplot(This);

% Create PDF
%------------
% Create PDf for figure handle and the latex command line.
% We need to pass in the top level report object's options that control
% orientation and paper size.
includeGraphics = '';
if ~isempty(This.handle) && ~isempty(get(This.handle,'children'))
    try
        includeGraphics = mycompilepdf(This,This.hInfo);
    catch Error
        try %#ok<TRYNC>
            close(This.handle);
        end
        utils.warning('report', ...
            ['Error creating figure ''%s''.\n', ...
            '\tMatlab says: %s'], ...
            This.title,Error.message);
        return
    end
end

% Close figure window or add its handle to the list of open figures
%-------------------------------------------------------------------
if ~isempty(This.handle)
    if This.options.close
        try %#ok<TRYNC>
            close(This.handle);
        end
    else
        addfigurehandle(This,This.handle);
        if ~isempty(This.title)
            % If the figure stays open, add title.
            % TODO: Add also subtitle.
            grfun.ftitle(This.handle,This.title);
        end
    end
end

% Finish LaTeX code
%-------------------
C = [beginsideways(This),beginwrapper(This,7)];
C = [C,includeGraphics];
C = [C,finishwrapper(This),finishsideways(This)];
C = [C,footnotetext(This)];

end