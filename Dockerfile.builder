FROM ubuntu:xenial

# Install system prerequisites
RUN apt-get update
RUN apt-get install -y \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  curl

# Install Docker CE
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  apt-get update && apt-get install -y docker-ce

# Install universe prerequisites
RUN apt-get install -y \
  build-essential \
  python3-setuptools \
  python3-jsonschema \
  jq \
  zip \
  git && \
  curl https://bootstrap.pypa.io/ez_setup.py | python3

# Copy the Mesosphere Universe sources
WORKDIR /universe
COPY . .

# Parameterize the package selection
RUN sed -i -e 's/--selected/--include="$(DCOS_PACKAGES)"/' /universe/docker/local-universe/Makefile

# Define a custom make task
RUN echo "custom-universe: base local-universe" >> /universe/docker/local-universe/Makefile

# Set default working directory to the local universe
WORKDIR /universe/docker/local-universe

# Build the custom DC/OS universe
CMD ["make", "custom-universe"]
