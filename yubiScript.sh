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
hash dd 2>/dev/null || { echo >&2 "I require dd but it's not installed.  Aborting."; exit 1; }
hash openssl 2>/dev/null || { echo >&2 "I require openssl but it's not installed.  Aborting."; exit 1; }
hash yubico-piv-tool 2>/dev/null || { echo >&2 "I require yubico-piv-tool but it's not installed.  Aborting."; exit 1; }

#3)	Prepare the Yubikey NEO
#3a)	Generate a new token management key
key=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
#echo "Your new token management key is:"
#echo $key
#3b)	Set the token management key
#yubico-piv-tool -a set-mgm-key -n $key

#4)	Change the token PIN and PUK
#4a)	Generate a new PIN
pin=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-6`
echo $pin
#4b)	Generate a new PUK
puk=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-8`
echo $puk
#4c)	Set the token PIN and PUK
#yubico-piv-tool -k $key -a change-pin -P 123456 -N $pin
#yubico-piv-tool -k $key -a change-puk -P 12345678 -N $puk
#	PROMPT FOR USER INPUT?
#echo -n "Enter your new PIN and press [ENTER]: "
#read pin
#echo -n "Enter your new PUK and press [ENTER]: "
#read -n 1 puk
#echo
# size=${#myvar}

if [ ${#pin} -lt 6 ] ; then echo "PIN too short!" ; fi
if [ ${#puk} -lt 8 ] ; then echo "PUK too short!" ; fi

#To reset PIN/PUK retry counter AND codes (default pin 123456 puk 12345678):
#yubico-piv-tool -k $key -a pin-retries --pin-retries 3 --puk-retries 3



# 9A, 9C, 9D, 9E: RSA 1024, RSA 2048, or ECC secp256r1 keys (algorithms 6, 7, 11 respectively).

# Change the CHUID (mostly for Windows)
