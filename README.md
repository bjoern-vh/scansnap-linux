# scansnap-linux
Easy driver installation for Fujitsu SnapScan S1300, S1300i, S1100 and S300 scanners in an linux system. At the moment only debian-based distributions are supported.

All credits go to Josh Archer: https://www.josharcher.uk/code/install-scansnap-s1300-drivers-linux/ and Gavin Carr: http://www.openfusion.net/linux/scansnap_1300i

## Installation methods

Before installation please ensure that the unit is connected and switched on.

### Git

git clone https://github.com/bjoern-vh/scansnap-linux
cd scansnap-linux

### wget

wget -q https://raw.githubusercontent.com/bjoern-vh/scansnap-linux/main/install.sh
chmod +x install.sh

### curl

curl --silent --output install.sh https://raw.githubusercontent.com/bjoern-vh/scansnap-linux/main/install.sh
chmod +x install.sh

### Manual

Download install.sh script manually to your computer. Missing files are automatically loaded during the installation process.


## Run installation

sudo ./install.sh

No matter which method you use, you must restart the computer at the end.
