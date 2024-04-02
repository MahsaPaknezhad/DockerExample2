# Example of Creating a Docker Container and a Conda Environment Within It

This example shows:
* How to create a docker container and create a cond environment in the container using a Dockerfile
* How to clone and install a private GitHub repository using a SSH key in the conda venv. 

# Instructions

Add the private GitHub repository that you aim to clone and install in your conda venv to the ```requirements.in``` file as shown below:
```
git+ssh://git@github.com/private_project.git@main
```

To install the SSH client and Git, add the following code to your Dockerfile:
```
# Install SSH client and Git
RUN apt-get update && \
    apt-get install -y \
    openssh-client \
    git \
    && rm -rf /var/lib/apt/lists/*
```

To clone a private repository in your requirements.in file you will need to use a SSH key. First, in your Dockerfile add the remote public key inside the known hosts of the container. Otherwise, asking to add the ssh key to known hosts will be prompted at the build stage and your build process will return an error.
```
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
```

In your Dockerfile use ```mount=type=ssh``` to load the ssh key and run the installation:

```
# Install packages from requirements.in
RUN --mount=type=ssh pip-compile /requirements.in
RUN --mount=type=ssh pip install -r /requirements.txt
```

The --ssh command is only available with DOCKER_BUILDKIT so, declare it as an environment variable before building, then it is forwarded to the container.

```
export DOCKER_BUILDKIT=1
```

Build the Docker Image by running the following command:
```
docker build --ssh default=$HOME/.ssh/id_rsa -t model_trainer .
```

