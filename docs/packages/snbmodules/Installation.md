# Installation SNBmodules requirements

## Installing RClone
### Installing GO
```
sudo dnf install golang
```
### Clone RClone lib
```
git clone https://github.com/rclone/rclone.git
```
### Build lib in rclone
Better to Build with the evironment already sourced.
```
go build --buildmode=c-shared -o librclone.so github.com/rclone/rclone/librclone
```
### Export var (add to the env.sh file)
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/lib/folder
export RCLIB_INC=/path/to/lib/folder
export RCLIB_LIB=/path/to/lib/folder
```
### Run local server
```
cd rclone/
curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
rm rclone-current-linux-amd64.zip
cd rclone-current-linux-amd64
./rclone serve http / --addr IP:PORT(8080) --buffer-size '0' --no-modtime --transfers 200 -v --multi-thread-cutoff=50G --multi-thread-streams=16
```

## Install libtorrent
### Clone lib
```
git clone --recurse-submodules https://github.com/arvidn/libtorrent.git
```
### Build lib in rclone
```
mkdir build;cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17 -G Ninja ..
ninja
```
### Export var (add to the env.sh file)
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/lib/folder/build
export LIBTORRENT_INC=/path/to/lib/folder/include
export LIBTORRENT_LIB=/path/to/lib/folder/build
```

-----

<font size="1">
_Last git commit to the markdown source of this page:_


_Author: Leo Joly_

_Date: Fri Sep 22 18:12:31 2023 +0200_

_If you see a problem with the documentation on this page, please file an Issue at [https://github.com/DUNE-DAQ/snbmodules/issues](https://github.com/DUNE-DAQ/snbmodules/issues)_
</font>
