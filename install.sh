#!/bin/sh

# This is an install script for notes

# Yay, Echo self documents! :D
echo "Checking for root..."
    [ "$(whoami)" != "root" ] && exec sudo -- "$0" -s -- "$@"

# This has to be defined after root elevation or script will fail.
function assertInstalled() {
    for var in "$@"; do
        if ! which $var &> /dev/null; then
            echo "$var is required but not installed, exiting."
            exit 1
        fi
    done
}

# Make sure we have everything actually installed that we need to install this.
echo "Checking for dependencies..."
    assertInstalled bash curl tar mktemp install make

# Variable Definitions go here. 
user_home=`eval echo ~$SUDO_USER`
extract_dir=$(mktemp -d /tmp/notes.XXXXX)

echo "Downloading and extracting Notes from Repository..."
    latest_tarball=`curl -L https://api.github.com/repos/weavenet/notes/releases/latest |grep tarball_url | awk '{print $2}' |cut -d\" -f2`
    echo "Downloading '$latest_tarball'."
    curl -L $latest_tarball | tar -xzp -C $extract_dir --strip-components=1
if [ "$1" != "uninstall" ]; then
    echo "Installing notes..."
    cd $extract_dir && make USERDIR=$user_home
else
    echo "Uninstalling notes..."
    cd $extract_dir && make uninstall USERDIR=$user_home
fi
echo "Cleaning up..."
    rm -rf $extract_dir
echo "All done."
