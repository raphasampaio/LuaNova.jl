#!/bin/bash

BASEPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$JULIA_1113 --project=$BASEPATH --interactive --load=$BASEPATH/revise.jl