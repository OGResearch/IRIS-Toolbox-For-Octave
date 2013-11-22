function list = nonunique(key)

[ukey,ans,index] = unique(key);
list = {};
if length(key) ~= length(ukey)
   while ~isempty(index)
      tmp = index(2:end) == index(1);
      if any(tmp)
         list{end+1} = ukey{index(1)};
      end
      index([true,tmp]) = [];
   end      
end

end