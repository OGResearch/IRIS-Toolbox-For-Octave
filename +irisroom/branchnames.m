function [List,NList] = branchnames(X,varargin)

isSort = ~isempty(varargin) && any(strcmpi(varargin,'sort'));

List = fieldnames(X);
List = List - {'SYNTAX','FILENAME','DESCRIPT','HELPTEXT'};

if isSort
    % Sort by true syntax keywords, not by file names: e.g. the keyword for
    % steady state versions of equations is `!!` whereas the help file name is
    % `sstate`.
    nList = length(List);
    trueName = cell(1,nList);
    for i = 1 : nList
        fileName = List{i};
        trueName{i} = X.(fileName).SYNTAX;
    end
    [~,inx] = sort(lower(trueName));
    List = List(inx);
end

List = List(:).';
NList = length(List);

end