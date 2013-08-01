function d = dp2db(this,d,varargin)
% dp2db  Convert model-specific datapack to database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(varargin)
    delog = true;
else
    delog = varargin{1};
    varargin(1) = [];
end

if isempty(varargin)
    comments = {};
else
    comments = varargin{1};
    varargin(1) = [];
end

%**************************************************************************

template = tseries();

if iscell(d)
    % Mean only.
    range = d{4};
    d = dp2db_(d);
    d = extras_(d);
else
    if isfield(d,'mean_') && ~isempty(d.mean_)
        range = d.mean_{4};
        d.mean = dp2db_(d.mean_);
        d.mean = extras_(d.mean);
    end
    if isfield(d,'var_') && ~isempty(d.var_)
        range = d.var_{4};
        % Convert variances to std devs.
        std = d.var_;
        for i = 1 : 3
            std{i} = sqrt(real(std{i})) + 1i*sqrt(imag(std{i}));
        end
        d.std = dp2db_(std);
        d.std = extras_(d.std);
    end
end

% Nested functions follow.

    % @ *******************************************************************
    function d = extras_(d)
        % Add parameters to database.
        for i = find(this.nametype == 4)
            d.(this.name{i}) = permute(this.Assign(1,i,:),[1,3,2]);
        end
        % Add comments to time series.
        for i = find(this.nametype <= 3)
            if isfield(d,this.name{i}) && istseries(d.(this.name{i}))
                if ~isempty(comments)
                    temp = comments;
                    nanIndex = ~cellfun(@ischar,temp);
                    temp(nanIndex) = this.namelabel(i);
                else
                    temp = this.namelabel{i};
                end
                d.(this.name{i}) = comment(d.(this.name{i}),temp);
            end
        end
    end
    % @ extras_().

    % @ *******************************************************************
    function b = dp2db_(p)
        b = struct();
        % Measurement variables.
        realid = real(this.solutionid{1});
        ylist = this.name(this.nametype == 1);
        for i = 1 : length(realid)
            y = permute(p{1}(i,:,:,:),[2,3,4,1]);
            if delog && this.log(realid(i))
                y = exp(y);
            end
            b.(ylist{i}) = replace(template,y,range(1));
        end
        % Transition variables.
        realid = real(this.solutionid{2});
        nx = length(this.solutionid{2});
        imagid = imag(this.solutionid{2});
        maxlag = -min(imagid);
        tempsize = size(p{2});
        X = [nan([nx,maxlag,tempsize(3:end)]),p{2}];
        startdate = range(1) - maxlag;
        t = maxlag + 1;
        for i = find(imagid < 0)
            parentRow = realid == realid(i) & imagid == 0;
            X(parentRow,t+imagid(i),:,:) = p{2}(i,1,:,:);
        end
        for i = find(imagid == 0)
            x = permute(X(i,:,:,:),[2,3,4,1]);
            if delog && this.log(realid(i))
                x = exp(x);
            end
            b.(this.name{realid(i)}) = replace(template,x,startdate);
        end
        % Shocks.
        elist = this.name(this.nametype == 3);
        for i = 1 : length(elist)
            e = permute(p{3}(i,:,:,:),[2,3,4,1]);
            b.(elist{i}) = replace(template,e,range(1));
        end
    end
    % @ dp2db_().

end