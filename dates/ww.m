function Dat = ww(Year,varargin)

if isempty(varargin)
    x = fwymonday(Year);
elseif length(varargin) == 1
    % First Monday in the year.
    per = varargin{1};
    if isequal(per,'end')
        per = weeksinyear(Year);
    end
    x = fwymonday(Year);
    x = x + 7*(per-1);
else
    x = datenum(Year,varargin{1},varargin{2});
end
Dat = day2ww(x);

end