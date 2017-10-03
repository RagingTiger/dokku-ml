# get base image
FROM ubuntu

# install binaries
RUN apt-get update && apt-get install -y \
	sudo \
	wget \
	curl

# create dokku home dir
WORKDIR /home/dokku

# copy dokku-ml source to dokku home dir
COPY . .
