#!/bin/bash
# NAME:
#  uek_kernel_fix.sh
#
# DESC:
#  Script which can be used to upgrade your Oracle VM Linux Kernel.
#  The scripting will check if all available packages are in place to
#  upgrade your Oracle VM server from a 2.6.39-300.32.6.el5uek Linux
#  kernel to a 2.6.39-400.215.9.el5uek Linux kernel.
#
# LOG:
#  VERSION---DATE--------NAME-------------COMMENT
#  0.1       26APR2015   Johan Louwers    Initial upload to github.com
#
# LICENSE:
#  The MIT License (MIT)
#
#  Copyright (c) 2015 Johan Louwers
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the "Software"),
#  to deal in the Software without restriction, including without limitation
#  the rights to use, copy, modify, merge, publish, distribute, sublicense,
#  and/or sell copies of the Software, and to permit persons to whom the
#  Software is furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.




# function used to check if all files exist and are present on the file system. If a
# file is not found the script will exit.
function check_file {
  if [ ! -f "$1" ]
    then
        echo -e "\tcheck failed : file $1 does not exists"
        error_exit
    else
        echo -e "\tcheck passed : file $1 found."
    fi
  }



# function used to exit the script in case of a error. We will print an error message
# to the screen and we will close the script.
function error_exit {
  echo -e "ERROR : script is aborted"
  exit 1
}


# function is used to check if all the dependencies are as we expect them to be and to
# check if the package to mitigate against the dependency is available.
function check_dependency {
   DEPCOUNT="$(rpm -Uvh --test $1 2>&1 | grep -v 'installed' | grep 'needed' | wc -l)"
   echo -e "\tnumber of dependencies for $1 is $DEPCOUNT"
   if [ $DEPCOUNT -gt 0 ]
    then
     echo -e "\tThe following dependencies are found :"
     rpm -Uvh --test $1 2>&1 | grep -v 'installed' | grep 'needed' | awk '{print $1;}' | while read -r line ; do
     echo -e "\tDependency : $line"
     if [[ $line == kernel-firmware ]]
      then
       DEPMITCOUNT="$(ls kernel-uek-firmware* | wc -l)"
      else
       DEPMITCOUNT="$(ls $line* | wc -l)"
    fi
     if [ $DEPMITCOUNT -gt 0 ]
      then
       echo -e "\tDependency : we found $DEPMITCOUNT packages availabel to mitigate this."
      else
       echo -e "\tDependency : we found no packages available to mitigate this."
       error_exit
      fi
    done
   fi
}


# The FILELIST array contains all the files we have identified that are needed to install the new
# kernel. This is specific to the 2.6.39-400.215.9.el5uek kernel. This might (will be) different
# for other versions of the kernel to be installed.
FILELIST=(
  aic94xx-firmware-30-2.el5.noarch.rpm
  atmel-firmware-1.3-7.el5.noarch.rpm
  ipw2100-firmware-1.3-11.el5.noarch.rpm
  ipw2200-firmware-3.1-4.el5.noarch.rpm
  ivtv-firmware-20080701-20.2.noarch.rpm
  iwl1000-firmware-128.50.3.1-1.1.el5.noarch.rpm
  iwl3945-firmware-15.32.2.9-4.el5.noarch.rpm
  iwl4965-firmware-228.61.2.24-2.1.el5.noarch.rpm
  iwl5000-firmware-8.24.2.12-3.el5.noarch.rpm
  iwl5150-firmware-8.24.2.2-1.el5.noarch.rpm
  iwl6000-firmware-9.176.4.1-2.el5.noarch.rpm
  iwl6050-firmware-9.201.4.1-2.el5.noarch.rpm
  netxen-firmware-4.0.590-0.1.el5.noarch.rpm
  rt61pci-firmware-1.2-7.el5.noarch.rpm
  rt73usb-firmware-1.8-7.el5.noarch.rpm
  zd1211-firmware-1.4-4.el5.noarch.rpm
  libertas-usb8388-firmware-5.110.22.p23-3.1.el5.noarch.rpm
  kernel-uek-firmware-2.6.39-400.215.9.el5uek.noarch.rpm
  kernel-uek-2.6.39-400.215.9.el5uek.x86_64.rpm
)

echo -e "installing new kernel 2.6.39-400.215.9.el5uek\n"
echo -e "STEP 1 : checking all packages and dependencies\n"

# run all packages mentioned in the FILELIST array through the checking to ensure we are fine. If
# an issue is found we will NOT go to the installation part and we will abort the script directly.
for i in "${FILELIST[@]}"
do
        echo -e "CHECK on $i"
        check_file $i
        check_dependency $i
        echo -e "\n"
done


# print additional information to the screen for the user to inform about the next step that will
# be undertaken as part of the script. This will be an introduction to the installation.
echo -e "STEP 2 : installing all required packages.\n"
echo -e "packages to be installed (in this order) :"


# Inform the user of each individual package that will be installed to the system as part of this
# kernel installation script. This is the order in which they will install.
for i in "${FILELIST[@]}"
do
  echo -e "\tabout to install : $i"
done


# install each individual package to the system using the rpm command. All information about the
# installation will be printed on the screen for the user to read and to be saved (if requried)
# for reporting purposes.
for i in "${FILELIST[@]}"
do
  echo -e "\n\tstart installation of : $i"
  rpm -ivh $i
done

echo -e "\tDone installing all packages for the new kernel. Reboot needed."
