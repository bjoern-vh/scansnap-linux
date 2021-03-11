# scansnap-linux
Easy driver installation for Fujitsu SnapScan S1300, S1300i, S1100, S300 and S300M scanners in an linux system. At the moment only debian-based distributions are supported.


## Installation methods

Before installation please ensure that the scanner is connected and switched on. No matter which method you use, you must restart the computer at the end before you can use the scanner.

### Git
```
git clone https://github.com/bjoern-vh/scansnap-linux
cd scansnap-linux
sudo ./install.sh
```

### wget/curl

Missing files are automatically loaded during the installation process.

```
wget -q https://raw.githubusercontent.com/bjoern-vh/scansnap-linux/main/install.sh
# or
curl --silent --output install.sh https://raw.githubusercontent.com/bjoern-vh/scansnap-linux/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

### Manual

Download install.sh script manually to your computer and run it as root user. Missing files are automatically loaded during the installation process.


## Credits
- Josh Archer: https://www.josharcher.uk/code/install-scansnap-s1300-drivers-linux/ 
- Gavin Carr: http://www.openfusion.net/linux/scansnap_1300i
