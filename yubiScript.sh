#!/bin/bash

#################################################
#  References:  
# -http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script/677212#677212
# - https://developers.yubico.com/yubico-piv-tool/YubiKey-NEO-PIV-Introduction.html
#################################################

PIN=123456
PUK=12345678
MGMT_KEY=010203040506070801020304050607080102030405060708



#################################################
#1)	Add the yubico-piv-tool binary to your path
#################################################
YUBI_BIN=$PWD/bin/
export PATH=$PATH:${YUBI_BIN}



#################################################
#2)	Check for the required binaries
#################################################
hash dd 2>/dev/null || { echo >&2 "I require dd but it's not installed.  Aborting."; exit 1; }
hash openssl 2>/dev/null || { echo >&2 "I require openssl but it's not installed.  Aborting."; exit 1; }
hash yubico-piv-tool 2>/dev/null || { echo >&2 "I require yubico-piv-tool but it's not installed.  Aborting."; exit 1; }



#################################################
#3)	Prepare the Yubikey NEO
#################################################
CHANGE_MGMT_KEY="no"
echo -n "Do you want to change your token management key? yes/no (no): "
read CHANGE_MGMT_KEY
if [ "$CHANGE_MGMT_KEY" == "yes" ] ; then 
	MGMT_KEY=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
	echo "Your new token management key is:"
	echo $MGMT_KEY
	yubico-piv-tool -a set-mgm-key -n $MGMT_KEY
fi



#################################################
#4)	Change the token PIN and PUK
#################################################
CHANGE_PIN="no"
echo -n "Do you want to change your token PIN? yes/no (no): "
read CHANGE_PIN
if [ "$CHANGE_PIN" == "yes" ] ; then 
	NEW_PIN=0
	while [ ${#NEW_PIN} -ne 6 ] ; do
		echo -n "Enter your new PIN and press [ENTER]: "
		read NEW_PIN
		if [ ${#NEW_PIN} -ne 6 ] ; then echo "PIN invalid (must be 6 chars)!" ; fi
	done
	yubico-piv-tool -k $MGMT_KEY -a change-pin -P $PIN -N $NEW_PIN
fi

CHANGE_PUK="no"
echo -n "Do you want to change your token PUK? yes/no (no): "
read CHANGE_PUK
if [ "$CHANGE_PUK" == "yes" ] ; then 
	NEW_PUK=0
	while [ ${#NEW_PUK} -ne 8 ] ; do
		echo -n "Enter your new PUK and press [ENTER]: "
		read NEW_PUK
		if [ ${#NEW_PUK} -ne 8 ] ; then echo "PUK invalid (must be 8 chars)!" ; fi
	done
	yubico-piv-tool -k $MGMT_KEY -a change-puk -P $PUK -N $NEW_PUK
fi










#### RANDOM
#To reset PIN/PUK retry counter AND codes (default pin 123456 puk 12345678):
#yubico-piv-tool -k $key -a pin-retries --pin-retries 3 --puk-retries 3



# yubico-piv-tool -k $key


# 9A, 9C, 9D, 9E: RSA 1024, RSA 2048, or ECC secp256r1 keys (algorithms 6, 7, 11 respectively).

# Change the CHUID (mostly for Windows)
