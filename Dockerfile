FROM kwhadocker/ubuntu18-postgres11:v5

# Move to root
WORKDIR /root/

# Install Ubuntu packages
# Install GEOS packages needed for basemap
# This layer costs 487MB in total
# Combined apt-get update install lines and added one more cleaning function
# why are we installing vim, curl, and git if we're starting with
# ubuntu18???

## Prerequisite: Updating apt-utils and software-properties-common
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils software-properties-common

# Next: Continuing with the rest of the apt packages,
# adding deadsnakes for python3.9
# and make a place for the requirements.txt files
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y \
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
        python3.9 \
        python3.9-distutils \
        chromium-chromedriver \
        ghostscript \
        python3-tk \
        python3-pip \
        libatlas-base-dev \
        libblas3 \
        liblapack3 \
        liblapack-dev \
        libblas-dev \
        gfortran \
        libjpeg-dev \
        libfreetype6-dev \
        libpng-dev \
        libxml2-dev \
        libxslt-dev \
        pkg-config \
        tig \
        libgeos-c1v5 \
        libgeos-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirement files
RUN mkdir -p buildreqs/
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt
COPY insurance-requirements.txt buildreqs/insurance-requirements.txt
COPY pvsyst-extraction-requirements.txt buildreqs/pvsyst-extraction-requirements.txt

# `python` is /usr/bin/python, a symlink. Delete old symlink, make new one.
# New one will point to python3.9 so that's the version we'll get when running
# `python`.
RUN ln -f /usr/bin/python3.9  /usr/bin/python
RUN python --version

# update pip
RUN python3.9 -m pip install pip==21.1.2

# required for arm architecture
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# Install marvin requirements
RUN python3.9 -m pip install numpy==1.20.3
RUN python3.9 -m pip install -r buildreqs/marvin-requirements.txt

# Install insurance requirements
RUN python3.9 -m pip install -r buildreqs/insurance-requirements.txt

# Install pvsyst-extraction requirements
RUN python3.9 -m pip install -r buildreqs/pvsyst-extraction-requirements.txt


# Run bash on startup
CMD ["/bin/bash"]
