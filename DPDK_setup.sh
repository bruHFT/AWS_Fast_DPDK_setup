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



# Clone dpdk-stable repository and checkout LTS version 22.11.4
git clone git://dpdk.org/dpdk-stable
cd dpdk-stable
git checkout v22.11.3

# Build DPDK
meson -Denable_kmods=true -Ddisable_libs=flow_classify build
ninja -C build
ninja -C build install


# Set hugepage (Linux only)
# single-node system
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Using Hugepage with the DPDK (Linux only)
mkdir /mnt/huge
mount -t hugetlbfs nodev /mnt/huge

# Close ASLR; it is necessary in multiple process (Linux only)
echo 0 > /proc/sys/kernel/randomize_va_space

# Clone dpdk-kmods repository
git clone git://dpdk.org/dpdk-kmods
cd dpdk-kmods/linux/igb_uio
make

sudo modprobe uio
sudo insmod ./igb_uio.ko wc_activate=1
python3 usertools/dpdk-devbind.py --status
sudo ip link set ens6 down
python3 usertools/dpdk-devbind.py --bind=igb_uio ens6 # assuming that use 10GE NIC




# Set hugepage (Linux only)
# single-node system
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Using Hugepage with the DPDK (Linux only)
mkdir /mnt/huge
mount -t hugetlbfs nodev /mnt/huge

# Close ASLR; it is necessary in multiple process (Linux only)
echo 0 > /proc/sys/kernel/randomize_va_space

# Offload NIC
modprobe uio
insmod /data/f-stack/dpdk/build/kernel/linux/igb_uio/igb_uio.ko wc_activate=1
insmod /data/f-stack/dpdk/build/kernel/linux/kni/rte_kni.ko carrier=on # carrier=on is necessary, otherwise need to be up `veth0` via `echo 1 > /sys/class/net/veth0/carrier`
python3 usertools/dpdk-devbind.py --status
sudo ip link set ens6 down
python3 usertools/dpdk-devbind.py --bind=igb_uio ens6 # assuming that use 10GE NIC


