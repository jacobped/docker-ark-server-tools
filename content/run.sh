#!/bin/bash

arkmanager="/usr/local/bin/arkmanager"

echo Running setup script

######################
## First time tasks ##
######################

doPrepareFolders() {
    # Make sure steam user owns specific folders
    sudo chown -R steam:steam /ark /home/steam /etc/arkmanager
    # sudo chown -R steam:steam /ark /etc/arkmanager

    cd /ark

    # Clear arkmanger config dir, so it's guaranteed to be empty.
    rm -fr /etc/arkmanager/*
    
    # Checks for and adds baseline configs to mapped directory
    if [ ! -d /ark/configs ] || [ ! -f /ark/configs/arkmanager.cfg ]; then
        echo "Config directory is empty. Adding baseline files.."
        mkdir /ark/configs && cp -r /ark-scripts/arkmanager/* /ark/configs/
    fi

    if [ ! -d /ark/logs ]; then
        mkdir /ark/logs # && cp -r /ark-scripts/arkmanager/* /ark/configs/
        mkdir /ark/logs/arktools
        mkdir /ark/logs/steam
    fi
}

######################
## Every time tasks ##
######################

doMapArkmanagerConfigs() {
    echo "Using configs from mapped /ark directory"
    sudo ln -s /ark/configs/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
    sudo ln -s /ark/configs/instances/ /etc/arkmanager/instances
    sudo ln -s /home/steam/Steam/logs /ark/logs/steam
}

doInstallGameServers() {
    echo "No game files found. Installing..."
	${arkmanager} install @all --verbose
}

doCheckServers() {
    directory_path=/ark/servers
    file_name=version.txt

    if [ ! -d /ark/servers  ] || [ ! $(find $directory_path -name $file_name) ]; then 
        doInstallGameServers
    else
        echo "hit else"
        # if [ ${BACKUPONSTART} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks/)" ]; then 
        # 	echo "[Backup]"
        # 	arkmanager backup
        # fi
    fi
}

doStart() {
    echo "Starting"
    ${arkmanager} start @all --verbose
}

stop() {
    echo "Saving worlds and shutting down.."
    ${arkmanager} stop --saveworld
	exit
}

awaitTermintaion() {
    [ -p /tmp/FIFO ] && rm /tmp/FIFO
    mkfifo /tmp/FIFO

    # Stop server in case of signal INT or TERM
    echo "Server(s) is running. Waiting until terminated..."
    trap stop INT
    trap stop TERM

    read < /tmp/FIFO &
    wait
}

main() {
    doPrepareFolders

    doMapArkmanagerConfigs

    doCheckServers

    doStart

    awaitTermintaion
}

main
