#!/bin/bash

# install dokku
wget https://raw.githubusercontent.com/dokku/dokku/v0.10.5/bootstrap.sh;
sudo DOKKU_TAG=v0.10.5 bash bootstrap.sh

# first setup CUDA
bash -c "$(curl -fsSL https://raw.githubusercontent.com/RagingTiger/cuda_setup/master/cuda_setup.sh)"

# then setup nvidia-docker
bash -c "$(curl -fsSL https://raw.githubusercontent.com/RagingTiger/nvidia-docker_setup/master/nvidia-docker_setup.sh)"

# now create dokku app
dokku apps:create tf-helloworld
dokku docker-options:add tf-helloworld deploy,run "$(curl localhost:3476/docker/cli)"
