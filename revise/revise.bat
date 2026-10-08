@echo off

SET BASEPATH=%~dp0

CALL julia --project=%BASEPATH% --interactive --load=%BASEPATH%\revise.jl
