# iso-rebuild

This is a bash script that can be used to customize or remaster a *buntu ISO file based on a configuration file and run-time arguments.

This is achieved by unpacking the squashfs from the specificed ISO file to your local filesystem, which is then set up as a chroot environment, in which packages are adding/removed based on a configuration file, and/or executing scripts throughout the process.

The inspiration for this comes from other similar utilities like remastersys, but did not fully suit my needs.

I have provided a default package.conf that has a list of packages that I commonly include in ISOs



In order to function properly, this script requires the following utilities (in no particular order):

bash
unsquashfs
chroot
mkisofs
isohybrid
mksquashfs
date
printf
sed
grep
ps
whoami
rsync
mount
umount
awk
fold
tput
dirname
basename
dd
cp
getopt
chmod
find
du
sort
date




```bash

$ ./iso-rebuild -h

This is designed to take a *buntu iso image and customize it by installing or removing packages as specified in the 
configuration.

Must be run as root.

  Usage:

    iso-rebuild [--base-iso|-i  /path/to/Input ISO] [options ...] 

  Overview:


   Required Input:

    --base-iso -i ISOFILE
      Select an iso file to start building the image off of.


   Output Options:

    --out-iso -o "OUT-ISOFILE-NAME"
      Specify the filename of the finished iso. Default is in the format [base-iso-name]-custom.[extension]

    --out-dir
      Specify the output dir for the ISOs that will be built. Default is /home/whofferbert/


    --vm-iso -V
      Run after the regular install, this will further modify the image with the specifications for VM packages 

    --out-vm-iso "OUT-VM-ISOFILE-NAME"
      Specify the filename of the finished iso. Default is in the format [base-iso-name]-custom-vm.[extension]

 
    --no-out-iso
      Do not rebuild the chroot into a squashfs for creating an iso
        
      
    --gz-iso
      Use gzip compression when building new squashfs instead of xz. (xz is default)
      xz compression provides the best compression ratio, but gzip is quicker.


    --write /dev/sdX
      Write the resulting iso to the specified device. Specified device must not be mounted.
      Will never write the vm-iso if produced as well.


   Build Options:

    --adjust -A /path/to/adjust_script
      Does not delete previous environment, but executes the specified adjust_script in the build environment

    --rebuild -R
      Does not delete previous environment, just rebuilds the squashfs from the 


    --preinstall
      Specify a script to run before updating and running package adjustments
        May be specified any number of times.

    --postinstall
      Specify a script to run after updating and running package adjustments
        May be specified any number of times.

    --vm-preinstall
      Specify a script to run before running VM package adjustments
        Same as --preinstall, but specific to VM ISOs

    --vm-postinstall
      Specify a script to run after running VM package adjustments
        Same as --postinstall, but specific to VM ISOs

    --package-config /path/to/package.conf
      Provide the path to the package configuration to use (default is 
/home/whofferbert/git/bash/iso-rebuild/package.conf)


    --no-install-recommends
      Do not install any additional recommended packages when rebuilding image. Default is to install recommended 
packages.

    --no-upgrade
      Do not run the package upgrade in the chroot environment. Default is to run a dist-upgrade.

    --no-dist-upgrade
      Run apt-get upgrade instead of apt-get dist-upgrade. Default is to run a dist-upgrade.

    --no-clean-chroot
      Do not clean up the chroot environment after running install. Default is to run the clean.


   Filesystem Options (can be specified multiple times):

    --add-archive "/path/to/local/archive.tar.gz"
      Extract the contents of a tar archive to the root of the filesystem
        tar -czvf ~/iso-rebuild-test/will.tar.gz /home/whofferbert/{.bashrc,.ssh,.vimrc}
 
    --add-zip "/path/to/local/zipfile.zip"
      Extract the contents of a zip file to the root of the filesystem


   UX Options:

    --label -l "CD LABEL"
      Specify the label name for the live image. Default is "iso-rebuild-custom"

    --casper-name
      Specify the name that will be used as both the user and hostname within the casper installer. Default is ""

    --release-url
      Specify the release url to display during the casper install. Default is 
"https://github.com/whofferbert/iso-rebuild"


   Local System Options:

    --workdir -w "/path/to/workdir"
      Specify workdir location. Default is /home/.iso-rebuild

    --no-clean-local-fs
      Does not delete the contents of the workdir after creating the ISOs.


   Debugging/Dev Options:

    --verbose
      Print all output generated when running in the chroot

    --quiet
      Surpress output from chroot, but print script info. (default)
      Note that this causes problems with interactive prompts, so you may want
      to try using --verbose if you seem to be having issues.

    --real-quiet
      Surpress all output but errors
    --silent
      Surpress all output, including errors. 

    --help -h
      Print this help text.



   Examples:

     # Create a new ISO with a custom label:
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.2-desktop-amd64.iso -l "Support Linux"

     # Create a new ISO and VM ISO with a custom label:
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.2-desktop-amd64.iso -V

     # Create an iso with a custom output name:
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso -o "mate-16.04.3-$(date 
+%Y%m%d-%H%M%S)-stable-x86_64.iso

     # create an ISO with additional .deb files installed via postinstall script and a matching archive :
     mkdir /tmp/deb/
     cp -t /tmp/deb/ /path/to/deb1 /path/to/deb2 ...
     tar -czvf /tmp/debs.tar.gz /tmp/deb/*
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --add-archive /tmp/debs.tar.gz --postinstall 
./post.sh 

     # create an ISO with some contents from your home directory on it :
     tar -czvf /tmp/whofferbert.tar.gz /home/whofferbert/{.ssh,.bashrc,.vimrc,Documents}
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --add-archive /tmp/whofferbert.tar.gz 

     # Optionally, you could include your whole home dir, 
     # but beware, the ISO may be large, and your filesystem needs size to handle it
     # You should not try this unless your home dir is less than 25% of your free space

     tar -czvf /tmp/whofferbert.tar.gz /home/whofferbert/.
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --add-archive /tmp/whofferbert.tar.gz 
     

     # add to the ISO a copy of /etc/default/sysstat that is enabled, via archive:
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --add-archive ./sysstat_on.tar.gz 

     # Create a new ISO and VM ISO with additional VM preinstall script:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso -V --vm-preinstall ./pp_vm_init.sh

     # Create a new ISO with additional preinstall script for adding a Google repository and Chrome:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --preinstall ./init.sh 

     # Create a new ISO with a custom package config file, and a specified output directory:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --package-config ./install_pkgs 

     # Create a new ISO with a custom package config file, and a specified output directory:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso --out-dir /home/whofferbert

     # You can combine most/all of the above options ...
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso -l "will-linux" --package-config 
./package.conf.example --add-archive ~/iso-rebuild-test/will.tar.gz --preinstall ./init.sh --no-install-recommends 
-o "will-buntu-16.04.iso" --add-archive ./sysstat_on.tar.gz --postinstall ./post.sh --out-dir ~/



```

