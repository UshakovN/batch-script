@echo off 

forfiles /P %1 /S /D -7 /C "cmd /c echo f|xcopy @path %2\@relpath /H /Y /C /R /S /I"

PAUSE