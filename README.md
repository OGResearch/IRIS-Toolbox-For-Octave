# IRIS Macroeconomic Modeling Toolbox compatible with GNU Octave

## IRIS for Octave

IRIS is a free, open-source toolbox for macroeconomic modeling and forecasting in Matlab® and GNU Octave. In a user-friendly command-oriented environment, IRIS integrates core modeling functions (including a flexible model file language which supports an automated code creation, a variety of tools for simulation, estimation, forecasting and model diagnostics, practical techniques for judgmental adjustments, and so on) with a supporting infrastructure (including time series analysis, data management and reporting).

*This version of IRIS is a fork of the [official IRIS Toolbox](https://github.com/IRIS-Solutions-Team/IRIS-Toolbox) as of July 19th, 2014. All the modifications made in the official IRIS Toolbox after that date are disregarded. There is a long-term plan to converge though...*

## Installing GNU Octave
Download and install the latest official version of GNU Octave from [the official web-site](http://octave.org).

If you are on Windows, it's a good idea to allow creating a desktop shortcut during installation as a simple run of octave.exe does not work in most cases.

## Other requirements
It's strongly recommended to install [MikTeX](http://miktex.org) or another TeX distributive available for your OS. This free typesetting system used to produce PDF reports in IRIS.

## Installing IRIS for Octave
**TO BE DONE JUST ONCE**

* Download the latest [release](https://github.com/OGResearch/iris4octave/releases) of iris4octave archive and store in a temporary location on your drive.
* Unzip the archive into a folder on user's hard drive (preferably without whitespace characters in the pathname), e.g. `C:\IRIS_Tbx`. This folder is called the IRIS root.
* Open GNU Octave.
* In Octave File Browser please navigate to the IRIS root folder.
* Type the command `iris4octaveinstall` in Octave Command Window and press enter.
  * If no errors were shown in the Command Window during installation process (simple warnings are fine, usually) you should be able to run `irisstartup` now.

## How to start IRIS in Octave
Don't use command `addpath` before starting IRIS up (as you might be used to in Matlab), just navigate to IRIS root using Octave File Browser before running `irisstartup` script.

## Issues when working with Octave
* Even though GNU Octave has been actively developing to provide you with the most of Matlab's features including Graphical User Interface and compatibility with the basic operating systems like MacOS, Linux and MS Windows, you may still face some troubles working in a particular environment. Should you face any issues please feel free to report it to iris4octave@ogresearch.com.
* You may also find it useful to check out [the list](http://wiki.octave.org/FAQ) of frequently asked questions (FAQ) for GNU Octave users. We would especially draw your attention to the [speed issue](http://wiki.octave.org/FAQ#Just-In-Time_compiler) which is most likely to be adressed in a newer Octave versions and a [graphical adapter issue](http://wiki.octave.org/FAQ#Missing_lines_when_printing_under_Windows_with_OpenGL_toolkit_and_Intel_integrated_GPU) which in most cases can be adressed by updating drivers of your graphical adapter.
* If you've had an older version of the GNU Octave installed on your machine it might happen that newly installed Octave does not start or crash while starting up. In this case you will have to remove `.config` folder from your user directory (usually, `C:\Users\<your_username>`).
