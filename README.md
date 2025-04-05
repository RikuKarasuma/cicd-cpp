# CI/CD C++ Boilerplate

# Build System
Uses CMakeLists, some examples have been left for retrieving libraries and compiling/linking those targets to tests, libraries and the final main executable.

CTests discovery and Catch2 test library has been added for quick test scaffolding.

CMakePresets has been included for easy differentiation between potential environments and possible compiler system changes.

cCache has been added and is defaultly assumed to be only required in local env.


# Build
./cicd/build.sh <env> Optional <clean> <run>
./cicd/build_local.sh Optional <clean> <run>
./cicd/build_stage.sh Optional <clean> <run>

<env> corresponds to CMakePresets.
<clean> will remove the ../build before building.
<run> will attempt to execute the compiled build at the end.

# Dockerfile

Builds an image from a minimum gcc:latest on the platform specified $BUILDPLATFORM param.
Uses clang++ 14 by default, this requires links to properly set up on the path.
Exposes 8080 assuming an API needs exposure.
Attempts to run ./build/app-api

./cicd/build_image.sh <platform> Optional <export>

<platform> used to specify the platform the image will be run on, eg. linux/amd64.
<export> exports image to .tar within ./cicd/images directory.

This script will build an image using buildx. It will be automatically loaded and tagged into docker. Tagging works by extracting the branch name using git. Then prepending app-api:<branch_name> to the image. Finally if export is specified this will save the .tar
to the ./cicd/images directory.

# Deployment

./cicd/deploy_local.sh Optional <image_tag>

<image_tag> will run the specified loaded image on docker

Will execute the specified loaded image on docker, mapping and exposing ports 8080:8080. If an <image_tag> is not specified, it will search ./cicd/images for the latest build image and attempt to execute that.

./cicd/deploy_image.sh <image_tag> <target_machine_ip>

<image_tag> the tag to deploy on the remote machine.
<target_machine_ip> IP/hostname of the target machine to deploy the image on.

Remote deployment script. Grabs the image within ./cicd/image with the specified <image_tag>. Creates an images directory within the remote machine, uses scp to transfer the image.tar, then attempts to load it into docker and execute the docker container by the specified <image_tag> on that remote machine.




