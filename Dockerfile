############################################################
# Dockerfile for running a ARK: Survival Evolved game server
# With ark-server-tools for management
############################################################

# FROM debian:9-slim
FROM cm2network/steamcmd:latest

ARG BUILD_DATE
ARG VCS_REF

MAINTAINER jacobpeddk
LABEL maintainer="jacobpeddk"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-url="https://github.com/jacobped/docker-ark-server-tools"
LABEL org.label-schema.vcs-ref=$VCS_REF

USER root

ENV REPOSITORY="jacobped/ark-server-tools" \
    GIT_TAG=v1.6.41 \
    DEBIAN_FRONTEND="noninteractive" \
    RUNLEVEL="1"

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
    locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
    's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
    /etc/sudoers && \
    # Add steam user to sudo group
    usermod -a -G sudo steam &&\
    mkdir -p /home/steam/ark-server-tools-install &&\
    chown -R steam:steam /home/steam

# Install ark-server-tools
USER steam
WORKDIR /home/steam/ark-server-tools-install

RUN git clone --no-checkout https://github.com/${REPOSITORY}.git /home/steam/ark-server-tools-install/git && \
    git -C /home/steam/ark-server-tools-install/git reset --hard $GIT_TAG && \
    cp -R git/tools/* ./ && \
    rm -fR git && \
    chmod +x install.sh && \
    sudo ./install.sh steam && \
    rm -fr /home/steam/ark-server-tools-install && \
    rm -fr /etc/arkmanager/*

WORKDIR /home/steam/

COPY content /ark-scripts
RUN sudo chown -R steam:steam /ark-scripts && \
    chmod +x /ark-scripts/run.sh

WORKDIR /ark
# CMD /bin/bash
CMD ["/bin/bash","-c","/ark-scripts/run.sh"]
