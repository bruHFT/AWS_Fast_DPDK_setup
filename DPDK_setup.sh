#!/bin/bash

# Set noninteractive mode to suppress prompts
export DEBIAN_FRONTEND=noninteractive

# Update package index and upgrade packages
echo -e "\n" | sudo apt update
echo -e "\n" | sudo apt upgrade -y
echo -e "\n" | sudo apt-get update

# Install necessary packages
yes | sudo apt install -y git linux-headers-$(uname -r) build-essential libelf-dev libpcap-dev
yes | sudo apt-get install libnuma-dev
# Install Meson and Ninja
yes | sudo python3 -m pip install meson ninja pyelftools
pip3 install pyelftools --upgrade
echo -e "\n" | sudo -E apt-get -y install python3-pip

# # Install development tools and dependencies
# yes | sudo apt install -y gcc make autoconf automake libtool


# # Clone dpdk-kmods repository
# git clone git://dpdk.org/dpdk-kmods
# cd dpdk-kmods/linux/igb_uio
# make
# sudo modprobe uio
# sudo insmod ./igb_uio.ko wc_activate=1

# # Clone dpdk-stable repository and checkout LTS version 22.11.4
# git clone git://dpdk.org/dpdk-stable
# cd dpdk-stable
# git checkout v22.11.4

# # Allocate hugepages
# echo 4096 | sudo tee /proc/sys/vm/nr_hugepages

# # Disable the interface
# sudo ip link set ens6 down

# # Bind the network interface to igb_uio driver
# sudo python3 usertools/dpdk-devbind.py --status
# sudo python3 usertools/dpdk-devbind.py --bind=igb_uio 00:06.0


# # Build DPDK
# meson -Denable_kmods=true -Ddisable_libs=flow_classify build
# cd build
# ninja

# # Install DPDK libraries
# sudo ninja install
# sudo ldconfig

# # Run example application
# cd ..
# cd examples/helloworld/
# make
# sudo ./dpdk-helloworld
