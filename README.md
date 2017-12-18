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




```bash

$ ./iso-rebuild -h

This is designed to take a *buntu iso image and customize it by installing or removing packages as specified in the configuration.

Must be run as root.

  Usage:

    iso-rebuild [--base-iso|-i  /path/to/ISOFILE] [options ...]

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


    --build-preinstall-script
      Specify a script to run before updating and running package adjustments

    --build-postinstall-script
      Specify a script to run after updating and running package adjustments

    --vm-preinstall-script
      Specify a script to run before running VM package adjustments

    --vm-postinstall-script
      Specify a script to run after running VM package adjustments

    --package-config /path/to/package.conf
      Provide the path to the package configuration to use (default is ./install_packages)


    --no-install-recommends
      Do not install any additional recommended packages when rebuilding image. Default is to install recommended packages.

    --no-upgrade
      Do not run the package upgrade in the chroot environment. Default is to run a dist-upgrade.

    --no-dist-upgrade
      Run apt-get upgrade instead of apt-get dist-upgrade. Default is to run a dist-upgrade.

    --no-clean
      Do not clean up the chroot environment after running install. Default is to run the clean.


   UX Options:

    --label -l "CD LABEL"
      Specify the label name for the live image. Default is "iso-rebuild-custom"

    --iso-username
      Specify the username that will be used with the casper installer. Default is "custom"

    --release-url
      Specify the release url to display during the casper install. Default is "https://github.com/whofferbert/iso-rebuild"


   Local System Options:

    --workdir -w "/path/to/workdir"
      Specify workdir location. Default is /home/.iso-rebuild


   Debugging/Dev Options:

    --quiet
      Surpress output from chroot, but print script info. 

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
     sudo iso-rebuild -i ~/ubuntu-mate-16.04.2-desktop-amd64.iso -l "Support Linux" -V

     # Create a new ISO and VM ISO with additional VM preinstall script:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso -o "mate-16.04.3-$(date +%Y%m%d-%H%M%S)-stable-x86_64.iso" -l "MATE 16.04.3 LTS" -V --package-config ./install_pkgs --vm-preinstall-script ./pp_vm_init.sh

     # Create a new ISO with additional preinstall script for ISO and a custom package config file:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso -o "mate-16.04.3-$(date +%Y%m%d-%H%M%S)-stable-x86_64.iso" -l "MATE 16.04.3 LTS" --build-preinstall-script ./init.sh --package-config ./install_pkgs

     # Create a new ISO with additional preinstall script for ISO, a custom package config file, and a specified output directory:
     time sudo iso-rebuild -i ~/ubuntu-mate-16.04.3-desktop-amd64.iso -o "mate-16.04.3-$(date +%Y%m%d-%H%M%S)-stable-x86_64.iso" -l "MATE 16.04.3 LTS" --build-preinstall-script ./init.sh --package-config ./install_pkgs -q --out-dir /home/whofferbert


```

