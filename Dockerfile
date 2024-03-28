FROM continuumio/miniconda3:latest
  
# Install SSH client and Git
RUN apt-get update && \
    apt-get install -y \
    openssh-client \
    git \
    && rm -rf /var/lib/apt/lists/*

# Add the remote public key inside the known hosts of the container
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /root

# Copy environment.yml and requirements files
COPY env/environment.yml /
COPY env/requirements.in /

# Create Conda environment from environment.yml
RUN conda env create -f /environment.yml

# Activate Conda environment
SHELL ["conda", "run", "-n", "strand-prediction-venv", "/bin/bash", "-c"]

# Install pip-tools to handle requirements.in
RUN pip install pip-tools

# Install packages from requirements.in
RUN --mount=type=ssh pip-compile /requirements.in
RUN --mount=type=ssh pip install -r /requirements.txt

# Set entrypoint to activate Conda environment
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "myenv", "/bin/bash", "-c"]