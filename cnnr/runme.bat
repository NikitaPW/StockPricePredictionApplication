ECHO SCRIPT IS STARTED
set /p RPATH=<RPath.txt
set PATH=%PATH%;%RPATH%
Rscript runme.R
