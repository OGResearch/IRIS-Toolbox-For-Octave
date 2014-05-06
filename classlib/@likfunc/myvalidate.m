function This = myvalidate(This,DataList,ParamList)

This.userFunc = strrep(This.userFunc,' ','');
This.userFunc = strrep(This.userFunc,sprintf('\t'),'');
This.userFunc = strrep(This.userFunc,sprintf('\n'),'');
This.userFunc = strrep(This.userFunc,sprintf('\r'),'');
func = This.userFunc;

% Validate data and param names.
doValidateNames();
nd = length(DataList);
np = length(ParamList);
This.name = [DataList,ParamList];
This.nameType = [ones(1,nd),2*ones(1,np)];

% Replace data names with !{10}.
for id = find(This.nameType == 1)
	ptn = ['\<',This.name{id},'\>(?!\.)'];
    rpl = sprintf('!{%g}',id);
    func = regexprep(func,ptn,rpl);
end

% Replace parameter names with #{10-nd}.
for ip = find(This.nameType == 2)
	ptn = ['\<',This.name{ip},'\>(?!\.)'];
    rpl = sprintf('#(%g)',ip-nd);
    func = regexprep(func,ptn,rpl);
end

% Catch undeclared names.
und = regexp(func,'\<[A-Za-z]\w*\>(?![\.\(])','match');
if ~isempty(und)
    utils.error('likfunc:myparse', ...
        'Undeclared name in the likelihood function: ''%s''.', ...
        und{:});
end

func = strrep(func,'!{','x{');
func = strrep(func,'#(','p(');

try
    if ismatlab
        s2fH = @str2func;
    else
        s2fH = @mystr2func;
    end
    switch This.form
        case ''
            func = s2fH(['@(x,p) -log(',func,')']);
        case 'log'
            func = s2fH(['@(x,p) -(',func,')']);
        case '-log'
            func = s2fH(['@(x,p) ',func]);
    end
catch E
    utils.error('likfunc:myparse', ...
        ['Error creating a function handle for the likelihood function.\n', ...
        '\tMatlab says: %s'], ...
        E.message);
end

This.minusLogLikFunc = func;

% Nested functions...


%**************************************************************************
    function doValidateNames()
        if ischar(DataList)
            DataList = regexp(DataList,'\w+','match');
        end
        if ischar(ParamList)
            ParamList = regexp(ParamList,'\w+','match');
        end
        list = [DataList,ParamList];
        valid = cellfun(@isvarname,list);
        if any(~valid)
            utils.error('likfunc:myparse', ...
                'This is not a valid data or parameter name: ''%s''.', ...
                list{~valid});
        end
        nonunique = strfun.nonunique(list);
        if ~isempty(nonunique)
            utils.error('likfunc:myparse', ...
                'This name is declared more than once: ''%s''.', ...
                list{~valid});
        end            
    end % doValidateNames()


end