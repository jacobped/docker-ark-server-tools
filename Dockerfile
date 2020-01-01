############################################################
# Dockerfile for running a ARK: Survival Evolved game server
# With ark-server-tools for management
############################################################

FROM debian:9-slim

ARG BUILD_DATE
ARG VCS_REF

MAINTAINER jacobpeddk
LABEL maintainer="jacobpeddk"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-url="https://github.com/jacobped/docker-ark-server-tools"
LABEL org.label-schema.vcs-ref=$VCS_REF

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
    bzip2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
    's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
    /etc/sudoers && \
    # Create steam user
    adduser \ 
    --disabled-login \ 
    --shell /bin/bash \ 
    --gecos "" \ 
    steam && \
    # Add steam user to sudo group
    usermod -a -G sudo steam

# Install steamcmd
USER steam
WORKDIR /home/steam/

RUN mkdir steamcmd ark-server-tools-install && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -C steamcmd -zxvf -

WORKDIR /home/steam/ark-server-tools-install

# Install ark-server-tools
RUN git clone --no-checkout https://github.com/${REPOSITORY}.git /home/steam/ark-server-tools-install/git && \
    git -C /home/steam/ark-server-tools-install/git reset --hard $GIT_TAG && \
    cp -R git/tools/* ./ && \
    rm -fR git && \
    ls -lah && pwd && \
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
