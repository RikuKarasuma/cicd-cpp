#!/bin/bash

set -eo pipefail

platform=$1
output_to_tar=$2

git_branch=$(git branch --show-current)

echo "Building image based on branch $git_branch."

app_name_tag="app-api:$git_branch"

# Build image.
image_id=$(
    docker buildx build --platform $platform -t $app_name_tag --load ..
)

echo "Built image $app_name_tag."

# Export to tar if specified.
if [[ "$output_to_tar" == "export" ]]; then

    echo "Exporting $app_name_tag to tar."

    if [ ! -d "./images" ]; then
        mkdir ./images
    fi

    docker save -o ./images/$app_name_tag.tar $app_name_tag
fi

