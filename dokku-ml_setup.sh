#!/bin/bash

# install dokku
wget https://raw.githubusercontent.com/dokku/dokku/v0.10.5/bootstrap.sh;
sudo DOKKU_TAG=v0.10.5 bash bootstrap.sh

# first setup CUDA
bash -c "$(curl -fsSL https://raw.githubusercontent.com/RagingTiger/cuda_setup/b71a8887ed704d02a00c9593c157cb5eb8d77450/cuda_setup.sh)"

# then setup nvidia-docker
bash -c "$(curl -fsSL https://raw.githubusercontent.com/RagingTiger/nvidia-docker_setup/743c8330e929ed773997b53798b8912760f878fe/nvidia-docker_setup.sh)"

# now create dokku app
dokku apps:create tf-helloworld
dokku docker-options:add tf-helloworld deploy,run "$(curl localhost:3476/docker/cli)"

