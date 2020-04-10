FROM kwhadocker/ubuntu18-postgres11:latest

# Move to root
WORKDIR /root/

# Install Ubuntu packages
# Install GEOS packages needed for basemap
# This layer costs 487MB in total
# Combined apt-get update install lines and added one more cleaning function
## TODO KE will python-dev, python-tk and python-pip still install
RUN apt-get update && apt-get install -y \
        strace \
        build-essential \
        lsof \
        vim \
        curl \
        git \
        mc \
        sysstat \
        iotop \
        dstat \
        iptraf \
        screen \
        tmux \
        zsh \
        xfsprogs \
        libffi-dev \
        python-dev \
        chromium-chromedriver \
        python-tk \
        python-pip \
        libgeos-c1v5 \
        libgeos-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p buildreqs

# Copy requirement files
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt
COPY insurance-requirements.txt buildreqs/insurance-requirements.txt

# Install requirements
# Will also run buildreqs/marvin/requirements.txt since
# the insurance requirements file will point to marvin file
# This layer costs 1.28GB - not sure how to fix this issue.
RUN pip --no-cache-dir install -r buildreqs/marvin-requirements.txt
RUN pip --no-cache-dir install -r buildreqs/insurance-requirements.txt

# Python 3 setup
# KE TODO do we need this python3 setup or can we just install it
# in the apt-get section up there??
# what we're doing in app_tests.sh for python3
# set +u
# source venv/bin/activate
# set -u
# pip install --upgrade pip
# pip install -r py3requirements.txt



# Run bash on startup
CMD ["/bin/bash"]
