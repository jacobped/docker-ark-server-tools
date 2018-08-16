############################################################
# Dockerfile for running a ARK: Survival Evolved game server
# With ark-server-tools for management
############################################################

FROM debian:stable-slim

MAINTAINER Jacob Pedersen <jacob@jacobpedersen.dk>
LABEL maintainer="jacob@jacobpedersen.dk"

ENV REPOSITORY "jacobped/ark-server-tools"
ENV GIT_TAG v1.6.41

ENV DEBIAN_FRONTEND noninteractive
ENV RUNLEVEL 1

RUN apt-get update -y && apt-get install -y \
    bash \
    git \
    coreutils \
    findutils \
    perl \
    rsync \
    sed \
    tar \
    sudo \
    perl-modules \
    curl \
    lsof \
    libc6-i386 \
    lib32gcc1 \
    bzip2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
	's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
	/etc/sudoers

# Create steam user
RUN adduser \ 
	--disabled-login \ 
	--shell /bin/bash \ 
	--gecos "" \ 
	steam

# Add steam user to sudo group
RUN usermod -a -G sudo steam

# Install steamcmd
USER steam

WORKDIR /home/steam/

RUN mkdir steamcmd
WORKDIR steamcmd

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# RUN ./steamcmd.sh +login anonymous +quit

# Install ark-server-tools

WORKDIR /home/steam/

RUN mkdir ark-server-tools-install
WORKDIR ark-server-tools-install

RUN git clone https://github.com/${REPOSITORY}.git .
RUN git reset --hard $GIT_TAG

WORKDIR tools
RUN chmod +x install.sh
RUN sudo ./install.sh steam

WORKDIR /home/steam/
RUN rm -fr ark-server-tools-install
RUN rm -fr /etc/arkmanager/*

RUN sudo mkdir /ark-scripts
RUN sudo chown steam:steam /ark-scripts

WORKDIR /ark-scripts
COPY content/arkmanager ./arkmanager/
COPY content/run.sh ./

RUN sudo chown -R steam:steam /ark-scripts/*
RUN chmod +x /ark-scripts/run.sh


WORKDIR /ark

# CMD /bin/bash
CMD ["/bin/bash","-c","/ark-scripts/run.sh"]
