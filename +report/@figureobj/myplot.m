function This = myplot(This)
% myplot  [Not a public function] Plot figureobj object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if This.options.visible
    visibleFlag = 'on';
else
    visibleFlag = 'off';
end

%--------------------------------------------------------------------------

This = myplot@report.basefigureobj(This);

% Open new figure window
%------------------------
This.handle = figure('visible',visibleFlag);
% Apply user-supplied figure options one by one so that we catch errors.
if ~isempty(This.options.figureoptions)
    for i = 1 : 2 : length(This.options.figureoptions)
        try %#ok<TRYNC>
            name = This.options.figureoptions{i};
            name = regexp(name,'\w+','match','once');
            value = This.options.figureoptions{i+1};
            set(This.handle,name,value);
        end
    end
end
% Apply styles to this figure only, do not cascade through.
if ~isempty(This.options.style) ...
        && isfield(This.options.style,'figure')
    qstyle(This.options.style,This.handle, ...
        'cascade=',false,'warning=',false);
end

% Determine subdivision
%-----------------------
sub = mysubplot(This);

% Plot all children
%-------------------
% Generate child graphs or empty spaces.
for i = 1 : length(This.children)
    % Both `subplot` and `plot` are object-specific; the method `subplot` does
    % not create any axes objects on emptyobj.
    ch = This.children{i};
    try
        ax = subplot(ch,sub{1},sub{2},i,'box','on');
        plot(ch,ax);
    catch Error
        utils.warning('report', ...
            ['Error plotting graph in figure ''%s''.\n', ...
            '\tMatlab says: %s'], ...
            This.title,Error.message);
    end
end

end