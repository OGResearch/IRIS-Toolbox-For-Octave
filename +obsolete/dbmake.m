function [dBase,list0,list1] = dbmake(primary,nameFilt,classFilt,mask,expr,append)
%
%DBMAKE  Generate new database entries (typically time series) in bulk according to a rule.
%     [db,list0,list1] = dbmake(db0,nfilter,cfilter,mask,expr)
%     [db,list,list1] = dbmake(db0,nfilter,cfilter,mask,expr,append)
%     db: struct (database), list0: cell array, list1: cell array, db0: struct (database),
%     nfilter: char or cell array, cfilter: char, mask: char, expr: char, append: logical

if ~isstruct(primary,'struct') || (~isa(nameFilt,'char') && ~isnumeric(nameFilt) && ~isa(nameFilt,'cell')) || (~isa(classFilt,'char') && ~isinf(classFilt)) || ~isa(mask,'char') || ~isa(expr,'char') || (nargin > 5 && ~isa(append,'logical'))
  error('Incorrect type of input argument(s).');
end  

if nargin < 6
  dBase = struct;
else
  if append == true
    dBase = primary;
  else
    dBase = struct;
  end
end

%% -------{function DBMAKE body}-----

if isnumeric(nameFilt) && isnan(nameFilt)
  nameFilt = '.*';
end

if isempty(classFilt)
  classFilt = Inf;
end

maxtokens = 9;

[list0,list1] = deal(cell([1,0]));

if isa(nameFilt,'char')
  for field = fieldnames(primary).'
    [string,tokens] = rexpn(field{1},nameFilt,maxtokens);
    if ~isempty(string)
      if strcmp(field{1},string) && (all(isinf(classFilt)) || isa(primary.(field{1}),classFilt))
        aux = rhoUnmask(expr,field{1},tokens,maxtokens);
        try      
          value = evalin('caller',aux);
        catch
          error(['Error evaluating the expr ''',aux,'''']);
        end
        list0{end+1} = field{1}; 
        list1{end+1} = rhoUnmask(mask,field{1},tokens,maxtokens);
        dBase.(list1{end}) = value;
      end
    end
  end
else
  list0 = nameFilt(:).';
  for field = list0
    aux = rhoUnmask(expr,field{1},{},0);
    try
      value = evalin('caller',aux);
    catch
      error(['Error in evaluation of ''',aux,'''']);      
    end
    list1{end+1} = rhoUnmask(mask,field{1},{},0);
    dBase.(list1{end}) = value;
  end
end

return

  %% -------{local function}-----
  
  function expr = rhoUnmask(mask,name,tokens,maxtokens);
  
  expr = strrep(mask,'lower($0)',lower(name));
  expr = strrep(expr,'upper($0)',upper(name));
  expr = strrep(expr,'$0',name);
  for i = 1 : maxtokens
    expr = strrep(expr,['$',sprintf('%g',i)],tokens{i,1});
  end
  
  return