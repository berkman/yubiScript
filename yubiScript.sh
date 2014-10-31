#!/bin/bash
# TODO:		Output all user settings to a file
# TODO:		Better notifications of what is happening


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
	PIN=$NEW_PIN
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
	PUK=$NEW_PUK
fi

# TODO:		Reset PIN/PUK to defaults (123456/12345678)
#yubico-piv-tool -k $key -a pin-retries --pin-retries 3 --puk-retries 3



##################################################################################################
# X)	Create a Strong Authentication key and certificate request
#	RSA1024", "RSA2048", "ECCP256" default=`RSA2048'
##################################################################################################
echo "Generating a private key"
yubico-piv-tool -k $MGMT_KEY -s 9a -A RSA2048 -a generate -o key.pub

echo "Generating a Strong Authentication certificate signing request (CSR)"
yubico-piv-tool -k $MGMT_KEY -s 9a -S '/CN=Mike Berkman/OU=test/O=cisco.com/' -P $PIN -a verify -a request-certificate -i key.pub -o request.csr



##################################################################################################
# X)	Request a Strong Authentication certificate from the CA
#	TODO:  do we want to print out the public key?
#	RSA1024", "RSA2048", "ECCP256" default=`RSA2048'
##################################################################################################
echo "Requesting a certificate from the CA"
# Generate a self-signed certificate:
#yubico-piv-tool -k $MGMT_KEY -s 9a -S '/CN=bar/OU=test/O=example.com/' -P $PIN -a verify -a selfsign -o certificate.cer -i key.pub

# Import a certificate from stdin:
#yubico-piv-tool -s 9a -a import-certificate -i certificate.cer



##################################################################################################
# X)	Import a S/MIME certificate
#	TODO: 
##################################################################################################
# Set a random chuid, import a key and import a certificate from a PKCS12 file with password test, into slot 9c:
#yubico-piv-tool -s 9c -i test.p12 -K PKCS12 -p P12_PASSWORD -a set-chuid -a import-key -a import-cert
