% sstatelang  Steady-state file language.
%
% Steady-state (sstate) files are a complementary tool to solve and analyse
% the steady states of more complex models. They allow you to create
% steady-state files independent of the original model files, and write the
% steady-state equations in different ways, manipulate their structure or
% order, split the problem into subblocks, and combine numerical and
% symbolic solutions. Using then the [sstate objects](sstatelang/Contents), you
% can compile and run stand-alone steady-state m-file functions based on
% your steady-state files.
%
% Input parameters
% =================
% 
% * [`!input`](sstatelang/input) - List of input parameters or variables.
% * [`!growthnames`](sstatelang/growthnames) - Pattern for creating growth names.
% 
% Equations and assignments
% ==========================
% 
% * [`!equations`](sstatelang/equations) - Block of equations or assignments.
% * [`!growthnames2imag`](sstatelang/growthnames) - Pattern for creating growth names.
% * [`!solvefor`](sstatelang/solvefor) - List of variables for which the current equations block will be solved.
% * [`!symbolic`](sstatelang/symbolic) - Attempt to solve the current equations block symbolically using the Symbolic Maths Toolbox.
% 
% Variables with steady state restricted to be positive
% ======================================================
% 
% * [`!log_variables`](sstatelang/logvariables) - Restrict the steady state of some of the variables to be positive.
% * [`!all_but`](sstatelang/allbut) - Inverse list of variables with positive steady states.
%
% Getting on-line help on sstate file language
% =============================================
%
%     help sstatelang
%     help sstatelang/keyword
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
