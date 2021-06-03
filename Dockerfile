FROM kwhadocker/ubuntu18-postgres11:v5

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
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt
COPY insurance-requirements.txt buildreqs/insurance-requirements.txt
COPY pvsyst-extraction-requirements.txt buildreqs/pvsyst-extraction-requirements.txt

# `python` is /usr/bin/python, a symlink. Delete old symlink, make new one.
# New one will point to python3.7 so that's the version we'll get when running
# `python`.
# Note: This seems to work locally when connected to a docker container, but not
# in the python commands run below, so they explicitly specify 'python3.7'.
RUN ln -f /usr/bin/python3.7  /usr/bin/python
RUN python --version

# update pip
RUN python3.7 -m pip install pip==21.1.1

# required for arm architecture
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# Create requirements dir
RUN mkdir -p buildreqs/

# Install marvin requirements
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt
RUN python3.7 -m pip install cython numpy==1.18.4
RUN python3.7 -m pip --no-cache-dir install -r buildreqs/marvin-requirements.txt --use-deprecated=legacy-resolver

# Install insurance requirements
COPY insurance-requirements.txt buildreqs/insurance-requirements.txt
RUN python3.7 -m pip --no-cache-dir install -r buildreqs/insurance-requirements.txt --use-deprecated=legacy-resolver

# Install pvsyst-extraction requirements
COPY pvsyst-extraction-requirements.txt buildreqs/pvsyst-extraction-requirements.txt
RUN python3.7 -m pip --no-cache-dir install -r buildreqs/pvsyst-extraction-requirements.txt --use-deprecated=legacy-resolver


# Run bash on startup
CMD ["/bin/bash"]
