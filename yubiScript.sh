#!/bin/bash

#################################################
#  References:  
# -http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script/677212#677212
# - https://developers.yubico.com/yubico-piv-tool/YubiKey-NEO-PIV-Introduction.html
#################################################

#1)	Add the yubico-piv-tool binary to your path
YUBI_BIN=$PWD/bin/
export PATH=$PATH:${YUBI_BIN}

#2)	Check for the required binaries
hash openssl 2>/dev/null || { echo >&2 "I require openssl but it's not installed.  Aborting."; exit 1; }
hash yubico-piv-tool 2>/dev/null || { echo >&2 "I require yubico-piv-tool but it's not installed.  Aborting."; exit 1; }


#3)	Check that a Yubikey NEO is connected



#4)	Prepare the Yubikey NEO
#4a)	Generate a new token management key
key=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
echo "Your new token management key is:"
echo $key
#4b)	Set the token management key
yubico-piv-tool -a set-mgm-key -n $key
