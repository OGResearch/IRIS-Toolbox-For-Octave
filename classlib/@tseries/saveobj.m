function this = saveobj(this)
% SAVEOBJ  [Not a public function] Prepare tseries object for saving on disk.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

if ~ismatlab
    this = struct('start',this.start,'data',this.data,'Comment',this.Comment,'UserData',this.UserData);
end

end