function newStr = myregexprep(oldStr,pat,repStr,varargin)

toChar = false;
if ischar(oldStr)
  oldStrCell = {oldStr};
  toChar = true;
elseif iscellstr(oldStr)
  oldStrCell = oldStr;
else
  newStr = NaN;
  return
end

nStr = numel(oldStrCell);
newStrCell = cell(size(oldStrCell));

for cx = 1 : nStr
  oldStr = oldStrCell{cx};

  repTok = regexp(repStr,'\$\{(.+?)\}','tokens');
  repTok = [repTok{:}];
  if isempty(repTok)
    newStr = regexprep(oldStr,pat,repStr,varargin{:});
  else
    [tok, mtch, mtchStart, mtchEnd] = regexp(oldStr,pat,'tokens','match','start','end');
    if ~isempty(mtch)
      newStr = oldStr(1:mtchStart(1)-1);
      for mx = 1:numel(mtch)
        tmpStr = '';
        tRepStr = repStr;
        for ix = 1:numel(repTok)
          funcRes = '';
          funcStr = repTok{ix};
          funcStr = strrep(funcStr,'$0',['''' mtch{mx} '''']);
          inputs = regexp(repTok{ix},'\$(\d+)','tokens');
          inputs = [inputs{:}];
          nInp = max(str2num(sprintf('%5s',inputs{:})));
          for jx = 1 : nInp
            if jx <= numel(tok{mx})
              tok{mx}{jx} = regexprep(tok{mx}{jx},'((?<!''))['']((?!''))','$1''''$2');
            else
              tok{mx}{jx} = '';
            end
            funcStr = strrep(funcStr,['$' int2str(jx)],['''' tok{mx}{jx} '''']);
          end
          funcRes = evalin('caller',funcStr);
          tRepStr = strrep(tRepStr,['${' repTok{ix} '}'],funcRes);
        end
        tmpStr = regexprep(oldStr(mtchStart(mx):mtchEnd(mx)),pat,tRepStr);
        newStr = [newStr, tmpStr];
        if mx < numel(mtch)
          newStr = [newStr, oldStr(mtchEnd(mx)+1:mtchStart(mx+1)-1)];
        end
      end
      newStr = [newStr, oldStr(mtchEnd(end)+1:end)];
    else
      newStr = oldStr;
    end
  end
  
  newStrCell{cx} = newStr;
end

if toChar
  newStr = newStrCell{1};
else
  newStr = newStrCell;
end