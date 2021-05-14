FROM kwhadocker/ubuntu18-postgres11:v5

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
        ghostscript \
        python-tk \
        python3-tk \
        python-pip \
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

# Python 3 setup
# KE TODO do we need this python3 setup or can we just install it
# in the apt-get section up there??

# Following section taken from
# https://github.com/kwhanalytics/postgis-heliostats-py3.5/blob/master/Dockerfile
# We need Python 3.5 because it's the last version that supports Pandas 0.18.
# Python 3.5 is no longer included in the default apt-get repo in Ubuntu 18.04, so we
# add the "Deadsnakes" repo where apt-get can find older Python version:
## KE edit 2020-04-12
# Adding software-properties-common to get add-apt-repository to work
RUN apt-get update && apt-get install -y software-properties-common && apt-get update

RUN add-apt-repository ppa:deadsnakes/ppa

# Install python 3.5 from deadsnakes
RUN apt-get update && apt-get install -y libpq-dev build-essential python3.5 python3.5-dev python3-pip python3.5-venv
RUN apt-get update && add-apt-repository ppa:deadsnakes/ppa && apt-get install -y libpython3.5-tk

# update pip to latest version that still includes the old dependency resolver.
# camelot-py currently requires numpy>=1.13.3 and pandas>=0.23.4
# which causes the new dependency resolver to fail.
# TODO switch back to latest version of pip this once our dependency graph is stable.
# RUN python3.5 -m pip install pip --upgrade
RUN python3.5 -m pip install pip==20.3.3
RUN python3.5 -m pip install wheel

# `python` is /usr/bin/python, a symlink. Delete old symlink, make new one.
# New one will point to python3.5 so that's the version we'll get when running
# `python`.
RUN ln -f /usr/bin/python3.5  /usr/bin/python

RUN python --version


RUN mkdir -p buildreqs/requirements

# Install marvin requirements
# Will also run buildreqs/marvin/requirements.txt since
# the insurance requirements file will point to marvin file
# This layer costs 1.28GB - not sure how to fix this issue.
# explicitly install numpy first?
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip install numpy==1.11.0

# Install marvin requirements
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt
# TODO remove legacy-resolver once we have stabilized our dependencies, see note above pip upgrade
RUN pip --no-cache-dir install -r buildreqs/marvin-requirements.txt --use-deprecated=legacy-resolver

# Install insurance requirements
COPY insurance-requirements.txt buildreqs/insurance-requirements.txt
RUN pip --no-cache-dir install -r buildreqs/insurance-requirements.txt

# Do we need to / want to create an ENTRYPOINT HERE?


# Run bash on startup
CMD ["/bin/bash"]
