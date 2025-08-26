@echo off

pushd %~dp0\..
julia +1.11 --project=. -e "import Pkg; Pkg.test(test_args=ARGS)" -- %*
popd