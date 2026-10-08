#!/bin/bash

BASEPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

julia --project=$BASEPATH --interactive --load=$BASEPATH/revise.jl