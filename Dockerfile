FROM kwhadocker/ubuntu18-postgres11:v4

# Move to root
WORKDIR /root/

# Install Ubuntu packages
# Install GEOS packages needed for basemap
# This layer costs 487MB in total
# Combined apt-get update install lines and added one more cleaning functio
## TODO KE
# will python-dev, python-tk and python-pip still install python2?
# can we install python3 here?
# why are we installing vim, curl, and git if we're starting with
# ubuntu18???

## Prerequisite: Updating apt-utils
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Next: Continuing with the rest of the apt packages
RUN apt-get update && apt-get install -y \
        strace \
        bash-completion \
        build-essential \
        lsof \
        vim \
        curl \
        git \
        mc \
        sysstat \
        iotop \
        dstat \
        htop \
        iptraf \
        screen \
        tmux \
        zsh \
        xfsprogs \
        libffi-dev \
        python-dev \
        chromium-chromedriver \
        python-tk \
        python3-tk \
        python-pip \
        tig \
        libgeos-c1v5 \
        libgeos-dev && \
    apt-get autoremove -y && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
    mkdir -p buildreqs/requirements

# Copy requirement files
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt
COPY insurance-requirements.txt buildreqs/insurance-requirements.txt

RUN python --version


# Install requirements
# Will also run buildreqs/marvin/requirements.txt since
# the insurance requirements file will point to marvin file
# This layer costs 1.28GB - not sure how to fix this issue.
# explicitly install numpy first?
# TODO remove legacy-resolver once we have stabilized our dependencies, see note above pip upgrade
RUN pip install numpy==1.11.0
RUN pip --no-cache-dir install -r buildreqs/marvin-requirements.txt --use-deprecated=legacy-resolver
RUN pip --no-cache-dir install -r buildreqs/insurance-requirements.txt

# Do we need to / want to create an ENTRYPOINT HERE?


# Run bash on startup
CMD ["/bin/bash"]
