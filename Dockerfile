FROM kwhadocker/ubuntu18-postgres11:v4

# Move to root
WORKDIR /root/

# Install Ubuntu packages
# Install GEOS packages needed for basemap
# This layer costs 487MB in total
# Combined apt-get update install lines and added one more cleaning function
# why are we installing vim, curl, and git if we're starting with
# ubuntu18???

## Prerequisite: Updating apt-utils
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Next: Continuing with the rest of the apt packages
# and make a place for the requirements.txt files
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
    	libpq-dev \
    	libpng-dev \
        pkg-config \
    	libfreetype6-dev \
        python3.7-dev \
        chromium-chromedriver \
        python3-tk \
        python3-pip \
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
COPY pvsyst-extraction-requirements.txt buildreqs/pvsyst-extraction-requirements.txt

# `python` is /usr/bin/python, a symlink. Delete old symlink, make new one.
# New one will point to python3.7 so that's the version we'll get when running
# `python`.
# Note: This seems to work locally when connected to a docker container, but not
# in the pythong commands run below, so they explicitly specify 'python3.7'.
RUN ln -f /usr/bin/python3.7  /usr/bin/python
RUN python --version


# update pip
RUN python3.7 -m pip install pip --upgrade


# Install requirements
# Will also run buildreqs/marvin/requirements.txt since
# the insurance requirements file will point to marvin file
# This layer costs 1.28GB - not sure how to fix this issue.
# explicitly install numpy first?
RUN python3.7 -m pip install numpy==1.18.5
RUN python3.7 -m pip --no-cache-dir install -r buildreqs/marvin-requirements.txt
RUN python3.7 -m pip --no-cache-dir install -r buildreqs/insurance-requirements.txt
RUN python3.7 -m pip --no-cache-dir install -r buildreqs/pvsyst-extraction-requirements.txt

# Do we need to / want to create an ENTRYPOINT HERE?


# Run bash on startup
CMD ["/bin/bash"]
