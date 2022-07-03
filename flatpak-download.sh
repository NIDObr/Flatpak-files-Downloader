#!/usr/bin/env bash

#------------------------------------------------------------------
# Autor: NidoBr
# Mais: < https://github.com/NIDObr >
# Email: coqecoisa@gmail.com
# Sobre: Download and generate a package containing the files of a flatpak
# License: GPL-3.0 license
#------------------------------------------------------------------

# Usage:
# ./flatpak_download.sh < flatpak repo >
# Ex:
# ./flatpak_download.sh com.google.Chrome

[ -z ${1} ] && {
	printf  "${0}: Error!\n\nUsage:\n	./flatpak_download.sh < flatpak repo >\nEx:\n	./flatpak_download.sh com.google.Chrome\n\n"
	exit 1
}

mkdir .tmp_download
cd .tmp_download
mkdir -p ostree

# Flathub Key
# Key file hash (sha256): '8bdc20abc4e19c0796460beb5bfe0e7aa4138716999e19c6f2dbdd78cc41aeaa'
wget https://flathub.org/repo/flathub.gpg

# Create the fakeroot environment
ostree init --repo ./ostree
ostree remote add --gpg-import=flathub.gpg --repo ./ostree flathub https://dl.flathub.org/repo/ || true
fakeroot ostree pull --repo ./ostree flathub app/${1}/x86_64/stable

# package information
_commit=$(cat ostree/refs/remotes/flathub/app/${1}/x86_64/stable)
_name=$(printf '%s\n' ${1} | awk -F'.' '{print $4}')
[ -z ${_name} ] && {
	_name=$(printf '%s\n' ${1} | awk -F'.' '{print $3}')
}

# Generate the final file
ostree export --repo ./ostree flathub:${_commit} --subpath files > ../"${_name}.tar"

cd ../
rm -rf .tmp_download
