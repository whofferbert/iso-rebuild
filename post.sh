#!/bin/bash
# William Hofferbert
#
# Example postinstall script to install 
# some extra .deb files
#
# expects .deb files in /tmp/deb/ ; IE:
#
# tar -czvf /tmp/deb_arch.tar.gz /tmp/deb/*
#
# and provide that to the script
#
if [ -d /tmp/deb/ ] 
  then
    dpkg -i /tmp/deb/*.deb
    if [ $? -ne 0 ]
      then
        apt-get -f install
        dpkg -i /tmp/archive/deb/*.deb
    fi
fi
exit 0
