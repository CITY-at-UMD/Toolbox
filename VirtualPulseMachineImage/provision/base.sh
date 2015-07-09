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
wget https://github.com/NREL/EnergyPlus/releases/download/v8.2.0-Update-1.2/EnergyPlus-8.2.0-8397c2e30b-Linux-x86_64.sh
sudo bash ./EnergyPlus-8.2.0-8397c2e30b-Linux-x86_64.sh

#OpenStudio
wget https://github.com/NREL/OpenStudio/releases/download/v1.7.0/OpenStudio-1.7.0.c5bad04b2c-Linux.deb
sudo dpkg -i OpenStudio-1.7.0.c5bad04b2c-Linux.deb
# update the install dependencies and try again
sudo apt-get -y install -f 
sudo dpkg -i OpenStudio-1.7.0.c5bad04b2c-Linux.deb