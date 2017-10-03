## About
Simple install script to setup a [**dokku**](https://github.com/dokku/dokku) server with **NVIDIA** drivers/libraries,
and [**nvidia-docker**](https://github.com/NVIDIA/nvidia-docker) to detect GPU devices to be mounted

## Install
First login to whatever server you want to run **dokku** on:
```
$ ssh username@host_address
```

### Setup
Then you will be executing a [shell script](https://github.com/RagingTiger/dokku-ml/blob/master/dokku-ml_setup.sh) to automate everything. If you trust
the script:
```
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/RagingTiger/dokku-ml/a4d568773eac6791df568ce2f36aa8812d0df42b/dokku-ml_setup.sh)"
```

Else download, read, and then execute:
```
$ curl -fsSL -o /tmp/dokku-ml_setup https://raw.githubusercontent.com/RagingTiger/dokku-ml/a4d568773eac6791df568ce2f36aa8812d0df42b/dokku-ml_setup.sh
$ bash /tmp/dokku-ml_setup
```

Once this is complete, open a browser to the address of the **dokku** server,
where you will need to paste your **ssh** public key (i.e. `id_rsa.pub`) into
the entry box, give a domain name, and click enter. This will now allow you,
as the administrator, to push code to **dokku** and have it automatically
executed.

### TF-Hello
After this completes you are going to want to download a "hello world"
example to your local machine (not your dokku server).
A [simple example](https://github.com/RagingTiger/tf-hello) has already been
provided below. This example should show that tensorflow is installed and can
find the mounted **GPU** devices. To get started:
```
$ git clone "https://github.com/RagingTiger/tf-hello" && cd tf-hello
```

Once in the **tf-hello** directory, you need to setup your **dokku git remote** ssh url:
```
$ git remote add dokku "ssh://dokku@your_dokku_host_address:tf-hello"
```
**NOTE**: If you changed your default **ssh** port, use this format:
```
$ git remote add dokku "ssh://dokku@your_dokku_host_address[:ssh_port]/tf-hello"
```
To clarify, your **ssh_port** is an optional parameter, and is only necessary
if you changed the **sshd_config** file to use a different **Port** than the
default 22 (see [Ubuntu Docs: SSH/OpenSSH/Configuring](https://help.ubuntu.com/community/SSH/OpenSSH/Configuring)):
```
$ git remote add dokku "ssh://dokku@your_dokku_host_address:1234/tf-hello"
```
The above example shows what the **ssh** URL would look like if the **sshd**
was set to listen on port **1234**.

### Deploying
Now you should be ready to go. Simply push the repo to dokku:
```
$ git push dokku master
Counting objects: 15, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (11/11), done.
Writing objects: 100% (15/15), 1.46 KiB | 0 bytes/s, done.
Total 15 (delta 2), reused 0 (delta 0)
-----> Cleaning up...
-----> Building tf-hello from dockerfile...
remote: build context to Docker daemon  9.216kB
Step 1/3 : FROM tensorflow/tensorflow:latest-gpu
 ---> 4ca1d30fcd9b
Step 2/3 : WORKDIR ./
 ---> Using cache
 ---> bc18e87b54ea
Step 3/3 : COPY . .
 ---> Using cache
 ---> b0ce1011a9fe
Successfully built b0ce1011a9fe
Successfully tagged dokku/tf-hello:latest
-----> Releasing tf-hello (dokku/tf-hello:latest)...
-----> Deploying tf-hello (dokku/tf-hello:latest)...
-----> Attempting to run scripts.dokku.predeploy from app.json (if defined)
-----> App Procfile file found (/home/dokku/tf-hello/DOKKU_PROCFILE)
-----> DOKKU_SCALE file found (/home/dokku/tf-hello/DOKKU_SCALE)
=====> app=1
-----> Attempting pre-flight checks
       Non web container detected: Running default container check...
-----> Waiting for 10 seconds ...
remote: App container failed to start!!
=====> tf-hello app container output:
       2017-10-03 18:51:58.991891: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE4.1 instructions, but these are available on your machine and could speed up CPU computations.
       2017-10-03 18:51:58.991913: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE4.2 instructions, but these are available on your machine and could speed up CPU computations.
       2017-10-03 18:51:58.991918: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use AVX instructions, but these are available on your machine and could speed up CPU computations.
       2017-10-03 18:51:58.991921: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use AVX2 instructions, but these are available on your machine and could speed up CPU computations.
       2017-10-03 18:51:58.991924: W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use FMA instructions, but these are available on your machine and could speed up CPU computations.
       2017-10-03 18:51:59.157910: I tensorflow/core/common_runtime/gpu/gpu_device.cc:955] Found device 0 with properties:
       name: GeForce GTX 1080
       major: 6 minor: 1 memoryClockRate (GHz) 1.7335
       pciBusID 0000:02:00.0
       Total memory: 7.92GiB
       Free memory: 7.80GiB
       2017-10-03 18:51:59.157933: I tensorflow/core/common_runtime/gpu/gpu_device.cc:976] DMA: 0
       2017-10-03 18:51:59.157938: I tensorflow/core/common_runtime/gpu/gpu_device.cc:986] 0:   Y
       2017-10-03 18:51:59.157947: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1045] Creating TensorFlow device (/gpu:0) -> (device: 0, name: GeForce GTX 1080, pci bus id: 0000:02:00.0)
=====> end tf-hello app container output
```
You will see a lot of different information in this output from the **dokku**
deploy, but pay attention to this main part:
```
Found device 0 with properties:
name: GeForce GTX 1080
major: 6 minor: 1 memoryClockRate (GHz) 1.7335
pciBusID 0000:02:00.0
Total memory: 7.92GiB
Free memory: 7.80GiB
```
That means that everything was setup right: the NVIDIA CUDA drivers/libs are
installed, **nvidia-docker** is working, and **dokku** is working. But how do
you setup your own **dokku** GPU apps?

## Dokku GPU Apps
Moving forward, you can easily build your own **GPU apps on dokku**, but there
are a few key points:

+ 1. you must use:
  `dokku docker-options:add your-app run,deploy $(curl local:346/docker/cli)`
+ 2. you must have a dockerfile with the correct environment setup.
+ 3. setup a `Procfile` like you would any **dokku** app.

We will now talk about each issue.

### Dokku Docker Options
While there may be other ways to configure **dokku** to use images with the
correct GPU devices/libraries mounted, the way used in this tutorial involves
[**nvidia-docker**](https://github.com/NVIDIA/nvidia-docker). This tool has a server (the [**nvidia-docker-plugin**](https://github.com/NVIDIA/nvidia-docker/wiki/nvidia-docker-plugin)) that
scans your filesystem for the libraries and device files necessary to run
GPU accelerated applications in containers. It is simply automating this task
for you. You can easily see the libraries/devices that need to be mounted
by sending a request to the **nvidia-docker-plugin** at `localhost:3476`:
```
$ curl localhost:3476/docker/cli
--volume-driver=nvidia-docker --volume=nvidia_driver_384.81:/usr/local/nvidia:ro --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidia0
```
Again, there is certainly room to improve on the **"solution"** presented
here, but at the least it works.

Now, we can use **dokku** to actually configure the docker options that will
be passed to a docker container when it is in any of the [three phases](http://dokku.viewdocs.io/dokku/advanced-usage/docker-options/#about-dokku-phases): **build**, **deploy**, or **run**. For example:
```
$ dokku docker-options:add your-app run,deploy $(curl local:346/docker/cli)
```
If you run this on your **dokku** server, it will add the **options** to
the application phases for **run** and **deploy**. If I wanted to check these
options, I can do the following:
```
$ dokku docker-options:report your-app
=====> your-app docker options information
       Docker options build:
       Docker options deploy: --volume-driver=nvidia-docker --volume=nvidia_driver_384.81:/usr/local/nvidia:ro --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidia0
       Docker options run:  --volume-driver=nvidia-docker --volume=nvidia_driver_384.81:/usr/local/nvidia:ro --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidia0
```

For example, the **tf-hello** app was setup as follows:
```
# on the dokku server
$ dokku apps:create tf-hello
$ dokku docker-options:add tf-hello deploy,run $(curl localhost:3476/docker/cli)
```

Now that we are convinced the correct libraries and devices will be mounted
into the docker container that will be running your app, we can construct the
right **Dockerfile**.

### Dockerfile
This issue is more simple. Most major frameworks have a **docker image** that
is prebuilt with all the necessary libraries/dependencies and environment
variables setup. If we look at the example **Dockerfile** from the
**tf-hello** repo we can see that [**Tensorflow**](https://github.com/tensorflow/tensorflow) develops its [own docker
image](https://hub.docker.com/r/tensorflow/tensorflow/):
```
$ cd tf-hello && cat Dockerfile
FROM tensorflow/tensorflow:latest-gpu

# Define working directory.
WORKDIR ./
COPY . .
```
We can see that the **base image** (the name referenced in front of the
**FROM** keyword in the **Dockerfile**) is the **tensorflow/tensorflow:latest-gpu**. This image is made to run any
**Tensorflow** code (it just needs **nvidia-docker** to mount the right
devices and libraries)

If you are unsure whether a given **docker image** will work, try pulling
the image directly to the dokku server, and running it with **nvidia-docker**:
```
$ ssh username@dokku_server_address
$ docker pull machine_learning_framework_image
$ nvidia-docker run -it machine_learning_framework_image bash
root@880dff0e47ee:/#
```
This should allow you to test some code in a **bash** session running in the
container.

For example if we run the **tensorflow/tensorflow:latest-gpu** image:
```
# on dokku server
$ nvidia-docker run -it tensorflow/tensorflow:latest-gpu bash
root@a843c11fa350:/notebooks#
root@a843c11fa350:/notebooks# ls
1_hello_tensorflow.ipynb  3_mnist_from_scratch.ipynb  LICENSE
2_getting_started.ipynb   BUILD
```

The other main issue, besides having the right **base image** is to make sure
you copy all the source code into the **docker container**. The keyword **COPY** is crucial to this as it will copy everything from the second path
to the first path (in this case **WORKDIR**). [Please see **Docker's** documentation on this subject](https://docs.docker.com/engine/reference/builder/)

### Procfile
This is the least difficult part, as it is completely the same as all other
**dokku** apps. For example, here is the the **Procfile** for **tf-hello**:
```
# from tf-hello directory
$ cat Procfile
app: python tfhello.py
```
Think of it this way: **dokku** will build the **docker image** defined in the
**Dockerfile**, look inside the image for the **Procfile**, and (hopefully
you have copied the code correctly into the container) execute the **Procfile**.

### Deploying
Once you are satisfied that the container will work, and you have the **Dockerfile** and **Procfile** written, simply complete the
above **3 steps** and `git push dokku master` and watch your own **GPU** app
execute on your **dokku** server !!!!
