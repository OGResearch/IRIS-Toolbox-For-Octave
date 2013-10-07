function This = model(This)
% model [Not a public function] Initialise theta parser object for model class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.caller = 'model';

% 1 - Measurement variables.
This.blkname{end+1} = '!measurement_variables';
This.nameType(end+1) = 1;
This.nameblk(end+1) = true;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = false;
This.flaggable(end+1) = true;
This.essential(end+1) = false;

% 2 - Transition variables.
This.blkname{end+1} = '!transition_variables';
This.nameblk(end+1) = true;
This.nameType(end+1) = 2;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = false;
This.flaggable(end+1) = true;
This.essential(end+1) = true;

% 3 - Parameters.
This.blkname{end+1} = '!parameters';
This.nameblk(end+1) = true;
This.nameType(end+1) = 4;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 4 - Log variables.
This.blkname{end+1} = '!log_variables';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = true;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 5 - Measurement equations.
This.blkname{end+1} = '!measurement_equations';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = true;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 6 - Transition equations.
This.blkname{end+1} = '!transition_equations';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = true;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = true;

% 7 - Deterministic trends.
This.blkname{end+1} = '!dtrends';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = true;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 8 - Reporting equations.
This.blkname{end+1} = '!reporting_equations';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = true;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 9 - Measurement shocks.
This.blkname{end+1} = '!measurement_shocks';
This.nameblk(end+1) = true;
This.nameType(end+1) = 31;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 10 - Transition shocks.
This.blkname{end+1} = '!transition_shocks';
This.nameblk(end+1) = true;
This.nameType(end+1) = 32;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 11 - Dynamic links.
This.blkname{end+1} = '!links';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = true;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 12 - Autoexogenise.
This.blkname{end+1} = '!autoexogenise';
This.nameblk(end+1) = false;
This.nameType(end+1) = NaN;
This.eqtnblk(end+1) = true;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% 13 - Exogenous variables in dtrends.
This.blkname{end+1} = '!exogenous_variables';
This.nameblk(end+1) = true;
This.nameType(end+1) = 5;
This.eqtnblk(end+1) = false;
This.flagblk(end+1) = false;
This.flaggable(end+1) = false;
This.essential(end+1) = false;

% Alternative names.
This.altblkname = { ...
    '!allbut','!all_but'; ...
    '!equations','!transition_equations'; ...
    '!variables','!transition_variables'; ...
    '!shocks','!transition_shocks'; ...
    };

% Alternative names with warning.
This.altblknamewarn = { ...
    '!coefficients','!parameters'; ...
    '!variables:residual','!shocks'; ...
    '!variables:innovation','!shocks'; ...
    '!residuals','!shocks'; ...
    '!outside','!reporting_equations'; ...
    '!equations:dtrends','!dtrends'; ...
    '!dtrends:measurement','!dtrends'; ...
    '!variables:transition','!transition_variables'; ...
    '!shocks:transition','!transition_shocks'; ...
    '!equations:transition','!transition_equations'; ...
    '!variables:measurement','!measurement_variables'; ...
    '!shocks:measurement','!measurement_shocks'; ...
    '!equations:measurement','!measurement_equations'; ...
    '!equations:reporting','!reporting_equations'; ...
    '!variables:log','!log_variables'; ...
    '!reporting','!reporting_equations'; ...
    };

% Other keywords -- do not throw an error message for these.
This.otherkey = { ...
    '!linear', ...
    '!ttrend', ...
    '!min', ...
    };

end