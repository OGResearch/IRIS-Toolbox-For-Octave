function [extract,varargin] = extractopt(list,varargin)

extract = {};
remainder = {};
extractindex = [];
remainderindex = [];
for i = 1 : 2 : length(varargin)
   index = strcmpi(list,varargin{i});
   if any(index)
      extractindex = [extractindex,i,i+1];
   else
      remainderindex = [remainderindex,i,i+1];
   end
end
extract = varargin(extractindex);
varargin = varargin(remainderindex);

end