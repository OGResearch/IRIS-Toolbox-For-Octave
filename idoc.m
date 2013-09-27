function idoc(varargin)

varargin{1} = strrep(varargin{1},'.','/');
root = irisroot();
[path,title] = fileparts(varargin{1});
if isempty(path) && ~isempty(title)
    path = title;
    title = 'Contents';
end
if ~isempty(path) && ~isempty(title)
    web(fullfile(root,'-help',path,[title,'.html']));
end

end