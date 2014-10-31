#!/bin/bash


##################################################################################################
# Variables
##################################################################################################
PIN=123456
PUK=12345678
MGMT_KEY=010203040506070801020304050607080102030405060708



##################################################################################################
# 1)	Add the yubico-piv-tool binary to your path
##################################################################################################
YUBI_BIN=$PWD/bin/
export PATH=$PATH:${YUBI_BIN}



##################################################################################################
# 2)	Check for the required binaries
##################################################################################################
hash dd 2>/dev/null || { echo >&2 "I require dd but it's not installed.  Aborting."; exit 1; }
hash openssl 2>/dev/null || { echo >&2 "I require openssl but it's not installed.  Aborting."; exit 1; }
hash yubico-piv-tool 2>/dev/null || { echo >&2 "I require yubico-piv-tool but it's not installed.  Aborting."; exit 1; }



##################################################################################################
# 3)	Change the Yubikey Management Key
##################################################################################################
CHANGE_MGMT_KEY="no"
echo -n "Do you want to change your token management key? yes/no (no): "
read CHANGE_MGMT_KEY
if [ "$CHANGE_MGMT_KEY" == "yes" ] ; then 
	MGMT_KEY=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
	echo "Your new token management key is:"
	echo $MGMT_KEY
	yubico-piv-tool -a set-mgm-key -n $MGMT_KEY
fi



##################################################################################################
# 4)	Change the token PIN and PUK
#	TODO:  What if the initial PIN/PUK are different?
#	TODO:  What if they are locked out?
##################################################################################################
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

# TODO:		LOCKED OUT
#To reset PIN/PUK retry counter AND codes (default pin 123456 puk 12345678):
#yubico-piv-tool -k $key -a pin-retries --pin-retries 3 --puk-retries 3




##################################################################################################
# X)	Create an Authentication certificate
#	TODO:  
#	RSA1024", "RSA2048", "ECCP256" default=`RSA2048'
##################################################################################################

# Generate the private key
yubico-piv-tool -k $MGMT_KEY -s 9a -A RSA2048 -a generate





#       Generate a certificate request with public key from stdin, will print the resulting request on stdout:
#          yubico-piv-tool -s 9a -S '/CN=foo/OU=test/O=example.com/' -P 123456 \
#            -a verify -a request

#       Generate a self-signed certificate with public key from stdin, will print the certificate, for later import, on stdout:
#          yubico-piv-tool -s 9a -S '/CN=bar/OU=test/O=example.com/' -P 123456 \
#            -a verify -a selfsign

#       Import a certificate from stdin:
#          yubico-piv-tool -s 9a -a import-certificate

#       Set a random chuid, import a key and import a certificate from a PKCS12 file with password test, into slot 9c:
#          yubico-piv-tool -s 9c -i test.pfx -K PKCS12 -p test -a set-chuid \
#            -a import-key -a import-cert

#       Delete a certificate in slot 9a:
#         yubico-piv-tool -a delete-certificate -s 9a


#################################################
# X)	Change the token CHUID
#	TODO:	all of it...
#################################################
# piv-tool -A M:9B:03 -s '00 db 3f ff 41 5c 03 5f c1 02 53 3c 30 19 d4 e7 39 ff 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 34 10 00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff 35 08 32 30 31 34 30 31 30 31 3e 00 fe'
# * 16 bytes, "11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff" above
