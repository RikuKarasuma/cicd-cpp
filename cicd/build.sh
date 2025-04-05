#!/bin/bash

processParams() {

    echo "Executing environment: ${env:? Missing environment (local or stage) ./build.sh <env> <options>}"

    for parameter in "${params[@]}"; do

        if [[ "$parameter" == "clean" ]]; then
            clean=1
        fi

        if [[ "$parameter" == "run" ]]; then
            execute_build=1
        fi
    
    done
}

clean() {

    if [[ "$clean" -eq 1 ]]; then

        echo "Cleaning object and binary directories..."
        rm -rf build
        echo "Completed cleaning."
    fi
}

compileLocal() {

    if [[ "$env" == "local" || "$env" == "stage" ]]; then

        echo "Starting clang++ compilation..."
        cmake --preset "$env"
        cmake --build build
        local status=$?

        if [[ "$status" -ne 0 ]]; then

            echo "Build failed with status: "$status"."
            echo "Exiting..."
            exit 1
        fi
    fi
}

compile() {

    compileLocal

    cd build
    make
    echo "Compilation complete."
}

executeOrExit() {

    if [[ "$execute_build" -eq 1 ]]; then
        ./app-api
    else
        echo "Exiting..."
        exit 0
    fi
}


echo
echo 
echo "####################################"
echo "#  ...Starting "$env" App build...   #"
echo "####################################"
echo
echo

echo "Parameters ["$#"] "$@""
echo "Processing selections..."

set -eo pipefail

params=("$@")
env=$1
execute_build=0
clean=0

# Gather optional params
processParams

# Navigate to project root.
cd ../

# Begin cleaning if specified.
clean

# Begin compiling for environment.
compile

# Execute the build if specified or exit.
executeOrExit



