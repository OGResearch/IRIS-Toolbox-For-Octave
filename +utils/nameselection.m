function index = nameselection(n,list,usrselect)

usrselect = usrselect(:).';

if isequal(usrselect,Inf)
    index = true(1,n);
elseif isnumeric(usrselect)
    index = false(1,n);
    index(usrselect) = true;
elseif iscellstr(usrselect) || ischar(usrselect)
    if ischar(usrselect)
        usrselect = regexp(usrselect,'\w+','match','once');
    end
    index = false(1,n);
    for i = 1 : length(list)
        index(i) = any(strcmp(list{i},usrselect));
    end
elseif islogical(usrselect)
    index = usrselect;
else
    index = false(1,n);
end

index = index(:).';

if length(index) > n
    index = index(1:n);
elseif length(index) < n
    index(end+1:n) = false;
end

end