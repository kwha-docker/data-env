FROM kwhadocker/ubuntu18-postgres11:latest

# Move to root
WORKDIR /root/

# Install Ubuntu packages
# Install GEOS packages needed for basemap
# This layer costs 487MB in total
# Combined apt-get update install lines and added one more cleaning function
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
    mkdir -p buildreqs/requirements

# Copy requirement files
COPY requirements.txt buildreqs/
COPY marvin-requirements.txt buildreqs/marvin-requirements.txt

# Install requirements
# Will also run buildreqs/marvin/requirements.txt since
# the insurance requirements file will point to marvin file
# This layer costs 1.28GB - not sure how to fix this issue.
RUN pip --no-cache-dir install -r buildreqs/requirements.txt

# Run bash on startup
CMD ["/bin/bash"]
