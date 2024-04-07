#!/bin/bash

# Set noninteractive mode to suppress prompts
export DEBIAN_FRONTEND=noninteractive

#!/bin/bash

# Update package index and upgrade packages
sudo apt update


# Install necessary packages
yes | sudo apt-get install libnuma-dev  # on Ubuntu
yes | apt-get install git gcc openssl libssl-dev linux-headers-$(uname -r) bc libnuma1 libnuma-dev libpcre3 libpcre3-dev zlib1g-dev python
# Install python3-pip and automatically select default option for restart prompt
echo -e "\n" | sudo -E apt-get -y install python3-pip
yes | pip3 install pyelftools --upgrade
yes | sudo python3 -m pip install meson ninja pyelftools
echo -e "\n" | sudo apt install gcc make libssl-dev net-tools    


# Clone dpdk-kmods repository
git clone git://dpdk.org/dpdk-kmods
cd dpdk-kmods/linux/igb_uio
make
sudo modprobe uio
sudo insmod ./igb_uio.ko wc_activate=1

# Clone dpdk-stable repository and checkout LTS version 22.11.4
git clone git://dpdk.org/dpdk-stable
cd dpdk-stable
git checkout v22.11.4

# Allocate hugepages
echo 4096 | sudo tee /proc/sys/vm/nr_hugepages

# Disable the interface
sudo ip link set ens6 down

# Bind the network interface to igb_uio driver
sudo python3 usertools/dpdk-devbind.py --status
sudo python3 usertools/dpdk-devbind.py --bind=igb_uio 00:06.0


# Build DPDK
meson -Denable_kmods=true -Ddisable_libs=flow_classify build
cd build
ninja

# Install DPDK libraries
sudo ninja install
sudo ldconfig

# Run example application
cd ..
cd examples/helloworld/
make
sudo ./dpdk-helloworld
