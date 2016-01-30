VirtualPulseMachineImage
=======

###Use vagrant to launch a virtual machine with OpenStudio
This creates a 64-bit ubuntu machine with OpenStudio installed, and optionally includes a desktop environment. 
This is can quickly create a VM if you need to run linux-specific software, as is the case in our group for our website.  

If you can manage to get the dependencies installed, use [NREL's OpenStudio cookbook instead](https://github.com/NREL-cookbooks/openstudio) instead as this will get you the most up-to-date versions of EnergyPlus and OpenStudio.

###Directions
- Download and install [Vagrant](https://www.vagrantup.com/downloads.html)
- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Download and install [CygWin](http://cygwin.com/install.html) and make sure ```c:\cygwin\bin\cygwin.exe``` is in your ```%path%``` environment variable.
- `git clone 'https://github.com/buildsci/Toolbox/tree/master/VirtualPulseMachineImage'`, or create a directory and copy the Vagrant file and provision folder to the directory.
- In terminal `cd` to the directory, and run `vagrant up`.  The default username and password for the vagrant virtual machine is 'vagrant'.
- you can comment out the desktop.sh script in the vagrant file if you do no need the desktop environment.

###Errors
- if you get this error: ```The executable 'cygpath' Vagrant is trying to run was not found in the %PATH% variable. This is an error. Please verify this software is installed and on the path.```, then try running the command in Windows PowerShell or GitShell.