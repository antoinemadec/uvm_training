#!/bin/bash

# recent git
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
sudo yum -y install git

sudo yum -y install epel-release
sudo yum -y install fuse-sshfs
sudo yum -y install gcc clang libcxx libstdc++-static gcc-c++
sudo yum -y install nodejs npm
sudo yum -y install autoconf automake
sudo yum -y install htop

# python3.8
sudo yum -y install gcc openssl-devel bzip2-devel libffi-devel
mkdir -p ~/src
cd ~/src
curl -O https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz
tar -xzf Python-3.8.1.tgz
cd Python-3.8.1/
./configure --enable-optimizations
sudo make altinstall

# ctags
mkdir -p ~/src
cd ~/src
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure --prefix=/usr
make
sudo make install

ssh-keygen
ssh-copy-id formation6@pc-formation6

sudo mkdir -p /formation
echo "formation6@pc-formation6:/formation /formation     fuse.sshfs    idmap=user,identityfile=/home/$USER/.ssh/id_rsa,allow_other 0 0" | sudo tee -a /etc/fstab
