#!/bin/bash

tag_name=$1
target_machine_ip=$2
image_file=$1.tar

echo "Deploying $tag_name to $target_machine_ip."

# Make image directory on target machine.
echo "Creating image dir if necessary."
ssh $target_machine_ip "[ -d '~/images' ] && echo 'Exists.' || mkdir ~/images"

# Copy docker image to target machine.
echo "Copying $tag_name to $target_machine_ip"
scp ./images/$image_file $target_machine_ip:~/images

ssh $target_machine_ip "docker load -i images/$image_file"

echo "Running image $tag_name container remotely"
ssh $target_machine_ip "docker container run -p 8080:8080 $image_tag"
