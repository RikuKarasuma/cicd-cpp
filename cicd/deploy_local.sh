#!/bin/bash

image_tag=$1

if [ -z "$image_tag" ]; then
    echo "Image not supplied... retrieving latest"
    retrieved_image=$(ls -ltr images | tail -1 | awk '{print $9}')
    image_tag="${retrieved_image%.tar}"
    echo "Retrieved tag $image_tag"
fi

echo "Running image $image_tag container locally"
docker container run -p 8080:8080 $image_tag