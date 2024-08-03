# Universal File Downloader

## This script downloads user-specified files from a pyhton http.server

### Installation
1. Copy in the terminal
```
wget https://github.com/Infamousmick/Universal-File-Downloader/blob/main/ufd.sh
```

### Usage 
1. Start http.server on Linux machine on localhost and a preferred port as 800
```
python -m http.server 800
```

```bash
# See current host running on port 800
lsof -i :800
# or
netstat -tuln | grep :800
# Close hosting with CTRL+C or
kill {PID}
# or
kill -9 {PID}
# Find the IP of the Kali device
ip addr show
```

2. Run the script
```
sh ufd.sh
```
