function SET = styleprocessor(H,varargin) %#ok<INUSL,STOUT>

varargin{1} = strtrim(varargin{1});
if strncmp(varargin{1},'!!',2)
    varargin{1} = varargin{1}(3:end);
end

eval(varargin{1});

if nargout > 0
    try
        SET; %#ok<VUNUS>
    catch %#ok<CTCH>
        utils.error('qreport', ...
            ['Style processor failed to create ', ...
            'the output variable SET: ''%s''.'], ...
            varargin{1});
    end
end

end