#!/sbin/sh

# This file contains parts from the scripts taken from the Open Gapps Project by mfonville.
#
# The Open Gapps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Functions & variables
tmp_path=/tmp

file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

if [ -f "/system/system/build.prop" ]; then
  rom_build_prop=/system/system/build.prop
  SYSTEM=/system/system
else 
  rom_build_prop=/system/build.prop
  SYSTEM=/system
fi

arch=$(file_getprop $rom_build_prop "ro.product.cpu.abi=")

# FaceLock
if (echo "$arch" | grep -qi "arm"); then
  cp -rf $tmp_path/facelock/arm/* $SYSTEM
fi

# Libs
if (echo "$arch" | grep -qi "armeabi"); then
  cp -rf $tmp_path/facelock/armlibs/lib/* $SYSTEM/lib
  mkdir -p $SYSTEM/vendor/lib
  cp -rf $tmp_path/facelock/armlibs/vendor/lib/* $SYSTEM/vendor/lib
elif (echo "$arch" | grep -qi "arm64"); then
  cp -rf $tmp_path/facelock/arm64libs/lib/* $SYSTEM/lib
  cp -rf $tmp_path/facelock/arm64libs/lib64/* $SYSTEM/lib64
  mkdir -p $SYSTEM/vendor/lib
  mkdir -p $SYSTEM/vendor/lib64
  cp -rf $tmp_path/facelock/arm64libs/vendor/lib/* $SYSTEM/vendor/lib
  cp -rf $tmp_path/facelock/arm64libs/vendor/lib64/* $SYSTEM/vendor/lib64
fi

# Make required symbolic links
if (echo "$arch" | grep -qi "armeabi"); then
  mkdir -p $SYSTEM/app/FaceLock/lib/arm
  ln -sfn $SYSTEM/lib/libfacenet.so $SYSTEM/app/FaceLock/lib/arm/libfacenet.so
elif (echo "$arch" | grep -qi "arm64"); then
  mkdir -p $SYSTEM/app/FaceLock/lib/arm64
  ln -sfn $SYSTEM/lib64/libfacenet.so $SYSTEM/app/FaceLock/lib/arm64/libfacenet.so
fi

# Cleanup
rm -rf /tmp/facelock
