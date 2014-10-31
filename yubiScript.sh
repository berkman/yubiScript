#!/bin/bash

#  References:  http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script/677212#677212

# Check for the required binaries
hash openssl 2>/dev/null || { echo >&2 "I require openssl but it's not installed.  Aborting."; exit 1; }
hash yubico-piv-tool 2>/dev/null || { echo >&2 "I require yubico-piv-tool but it's not installed.  Aborting."; exit 1; }
