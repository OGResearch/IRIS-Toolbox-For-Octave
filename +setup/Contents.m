    % setup  Installing IRIS.
%
% Requirements
% =============
% 
% * Matlab R2010a or later.
% 
% Optional components
% ====================
% 
% Optimization Toolbox
% ----------------------
% 
% The Optimization Toolbox is needed to compute the steady state of
% non-linear models, and to run estimation.
% 
% LaTeX
% -------
%
% LaTeX is a free typesetting system used to produce PDF reports in IRIS.
% We recommend MiKTeX, available from `www.miktex.org`.
% 
% Components not needed
% ======================
%
% Some components were needed in the past but are not any longer.
%
% X13-ARIMA-SEATS (formerly X12-ARIMA)
% -------------------------------------
% 
% Courtesy of the U.S. Census Bureau, the X13-ARIMA-SEATS (formerly
% X12-ARIMA) program is now incoporated in, and distributed with IRIS. You
% don't need to care about anything to be able to use it.
% 
% Symbolic Math Toolbox
% -----------------------
%
% IRIS is now equipped with its own symbolic/automatic differentiator. You
% do not need to have the Symbolic Math Toolbox installed to be able to
% compute exact Taylor expansions.
%
% Installing IRIS
% ================
% 
% Step 1
% --------
% 
% Download the latest IRIS zip archive, `IRIS_Tbx_#_YYYYMMDD.zip`, from
% `www.iris-toolbox.com`, and save it in a temporary location on your disk.
% 
% Step 2
% --------
% 
% Unzip the archive into a folder on your hard drive, e.g. `C:\IRIS_Tbx`.
% We will call this directory the IRIS root folder.
% 
% Installing IRIS on a network drive may cause some minor problems,
% especially on MS Windows systems; check out `help changeNotification` in
% Matlab.
% 
% Step 3
% --------
% 
% After installing a new version of IRIS, we recommend that you remove all
% older versions of IRIS from the Matlab search path, and restart Matlab.
% 
% Getting started
% -----------------
% 
% Each time you want to start working with IRIS, run the following line
% 
%     >> addpath C:\IRIS_Tbx; irisstartup
% 
% where `C:\IRIS_Tbx` needs to be, obviously, replaced with the proper IRIS
% root folder chosen in Step 2 above.
% 
% Alternatively, you can put the IRIS root folder permanently on the Matlab
% seatch path (using the menu File - Set Path), and only run the
% `irisstartup` command at the beginning of each IRIS session.
% 
% See also the section on [Starting and quitting IRIS](config/Contents).
% 
% Syntax highlighting
% ====================
% 
% You can get the model files (i.e. the files that describe the model
% equations, variables, parameters) syntax-highlighted. Syntax highlighting
% improves enormously the readability of the files. It helps you understand
% the model better, and discover typos and mistakes more quickly.
%
% Add any number of extensions you want to use for model files (such as
% `'mod'`, `'model'`, etc.) to the Matlab editor. Open the menu File -
% Preferences, and click on the Editor/Debugger - Language tab (make sure
% 'Matlab' is selected at the top as the Language). Use the Add button in
% the File extensions panel to associate any number of new extensions with
% the editor. Re-start the editor. The IRIS model files will be syntax
% highligted from that moment on.
% 

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
