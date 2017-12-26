#!/bin/bash
# by William Hofferbert
# example preinstall script

# need i386?
dpkg --add-architecture i386

# pre-accept some EULA
#echo "wireshark-common  wireshark-common/install-setuid boolean false" | debconf-set-selections
#echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

# add apt repos  here
# get google key 
#wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# comment out all repos
#sed -i 's/^\([ \t]*deb\)/#\1/g' /etc/apt/sources.list{,.d/*}

apt-get update
apt-get install -y google-chrome-stable
#apt-get install -y wireshark-common ttf-mscorefonts-installer

echo -en ""
