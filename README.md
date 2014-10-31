yubiScript
==========
Purpose:

We intend to create an executable python script which automates key generation, csr creation, and certificate issuance using the Yubico Yubikey NEO.  The certificates which get issued will be self-signed SMIME and Client Authentication certificates.  We intend to build functionality which will eventually allow the CSR to get submitted to a CA using SCEP or some other similar mechanism.

Requirements:

Python, PIV compatible Yubikey NEO

Resources:

yubi-piv-tool	https://developers.yubico.com/yubico-piv-tool/

yubikey-neo-manager	https://www.yubico.com/2014/04/yubikey-neo-manager-application/

Yubi Slots:
9a is for PIV Authentication
9c is for Digital Signature (PIN always checked)
9d is for Key Management
9e is for Card Authentication (PIN never checked)

