#!/bin/bash

# guarding against errors
set -e

# functions
dokku_install(){
  # the contents of this function are from dokku's own install instructions
  # (ref: http://dokku.viewdocs.io/dokku/getting-started/installation/#1-install-dokku)
  wget https://raw.githubusercontent.com/dokku/dokku/v0.10.5/bootstrap.sh;
  sudo DOKKU_TAG=v0.10.5 bash bootstrap.sh
}

cuda_install(){
  # From nvidia-docker docs: https://github.com/NVIDIA/nvidia-docker/wiki/Deploy-on-Amazon-EC2
  # Install official NVIDIA driver package
  sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
  sudo sh -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
  sudo apt-get update && sudo apt-get install -y --no-install-recommends linux-headers-generic dkms cuda-drivers

}

nvidiadocker_install(){
  # From nvidiai-docker docs: https://github.com/NVIDIA/nvidia-docker
  # Install nvidia-docker and nvidia-docker-plugin
  wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
  sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb

  # Test nvidia-smi
  sudo nvidia-docker run --rm nvidia/cuda nvidia-smi
}

setup_tfhello(){
  # setup app 'tf-hello' with the gpu devices arguments returned from then
  # nvidia-docker plugin REST API
  # (ref: https://github.com/NVIDIA/nvidia-docker/wiki/nvidia-docker-plugin)
  dokku apps:create tf-hello
  dokku docker-options:add tf-hello deploy,run "$(curl localhost:3476/docker/cli)"
}

main(){
  # install dokku
  dokku_install

  # setup CUDA
  cuda_install

  # setup nvidia-docker
  nvidiadocker_install

  # create tfhello test app with correct gpu devices mounted
  setup_tfhello
}

# run main after everything has downloaded
main
