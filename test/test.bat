@echo off

SET BASEPATH=%~dp0

CALL julia --project=%BASEPATH%\.. -e "import Pkg; Pkg.test(test_args=ARGS)" -- %*