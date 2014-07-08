function This = model(This)
% model [Not a public function] Initialise theta parser object for model class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% 1 - Measurement variables.
This.blkName{end+1} = '!measurement_variables';
This.nameType(end+1) = 1;
This.nameBlk(end+1) = true;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = true;
This.IxEssential(end+1) = false;

% 2 - Transition variables.
This.blkName{end+1} = '!transition_variables';
This.nameBlk(end+1) = true;
This.nameType(end+1) = 2;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = true;
This.IxEssential(end+1) = true;

% 3 - Parameters.
This.blkName{end+1} = '!parameters';
This.nameBlk(end+1) = true;
This.nameType(end+1) = 4;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = true;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 4 - Log variables.
This.blkName{end+1} = '!log_variables';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = true;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 5 - Measurement equations.
This.blkName{end+1} = '!measurement_equations';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 6 - Transition equations.
This.blkName{end+1} = '!transition_equations';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = true;

% 7 - Deterministic trends.
This.blkName{end+1} = '!dtrends';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 8 - Reporting equations.
This.blkName{end+1} = '!reporting_equations';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 9 - Measurement shocks.
This.blkName{end+1} = '!measurement_shocks';
This.nameBlk(end+1) = true;
This.nameType(end+1) = 3.1;
This.IxStdcorrBasis(end+1) = true;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 10 - Transition shocks.
This.blkName{end+1} = '!transition_shocks';
This.nameBlk(end+1) = true;
This.nameType(end+1) = 3.2;
This.IxStdcorrBasis(end+1) = true;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 11 - Dynamic links.
This.blkName{end+1} = '!links';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 12 - Autoexogenise.
This.blkName{end+1} = '!autoexogenise';
This.nameBlk(end+1) = false;
This.nameType(end+1) = NaN;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% 13 - Exogenous variables in dtrends.
This.blkName{end+1} = '!exogenous_variables';
This.nameBlk(end+1) = true;
This.nameType(end+1) = 5;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.eqtnBlk(end+1) = false;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = false;

% Alternative names.
This.altBlkName = { ...
    '!allbut','!all_but'; ...
    '!equations','!transition_equations'; ...
    '!variables','!transition_variables'; ...
    '!shocks','!transition_shocks'; ...
    '!autoexogenize','!autoexogenise'; ...
    };

% Alternative names with warning.
This.altBlkNameWarn = { ...
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
This.otherKey = { ...
    '!linear', ...
    '!ttrend', ...
    '!min', ...
    };

% Order in which values assigned to names will be evaluated in assign().
This.AssignBlkOrd = { ...
    '!parameters', ...
    '!exogenous_variables', ...
    '!transition_variables', ...
    '!measurement_variables', ...
    };

end