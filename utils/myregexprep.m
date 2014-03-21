function newStr = myregexprep(oldStr,pat,repStr,varargin)

repTok = regexp(repStr,'\$\{(.+?)\}','tokens');
repTok = [repTok{:}];

if isempty(repTok)
  newStr = regexprep(oldStr,pat,repStr,varargin);
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
        for jx = 1:numel(tok{mx})
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

