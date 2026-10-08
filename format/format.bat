@echo off

SET BASEPATH=%~dp0

CALL julia --project=%BASEPATH% %BASEPATH%\format.jl