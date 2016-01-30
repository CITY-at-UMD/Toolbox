sudo apt-get -y update
sudo apt-get -y upgrade

# build essentials for code
sudo apt-get -y install build-essential curl git xvfb libssl-dev zlib1g-dev 

# Ruby 2.0.0
wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p645.tar.gz
tar -xzvf ruby-2.0.0-p645.tar.gz
cd ruby-2.0.0-p645
sudo ./configure
sudo make 
sudo make install 
ruby -v
cd ~/

#EnergyPlus
wget https://github.com/NREL/EnergyPlus/releases/download/v8.4.0-Update1/EnergyPlus-8.4.0-09f5359d8a-Linux-x86_64.sh
sudo bash ./EnergyPlus-8.4.0-09f5359d8a-Linux-x86_64.sh

#OpenStudio
wget https://openstudio-builds.s3.amazonaws.com/1.10.0/OpenStudio-1.10.0.bc05249524-Linux.deb
sudo dpkg -i OpenStudio-1.10.0.bc05249524-Linux.deb
# update the install dependencies and try again
sudo apt-get -y install -f
sudo dpkg -i OpenStudio-1.10.0.bc05249524-Linux.deb