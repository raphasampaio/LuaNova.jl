@echo off

SET BASEPATH=%~dp0

CALL julia +1.12 --project=%BASEPATH%\.. -e "import Pkg; Pkg.test(test_args=ARGS)" -- %*