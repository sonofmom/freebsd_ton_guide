#!/bin/sh
# This script will generate PKI Keys and control record for TON Node.
#
# Required params:
# PORT number of control server
#
# Prerequesites:
# Executable generate-random-id (part of TON node software) in PATH
#
#

####################################################################
#
# Some basic parameters
#

SERVER_KEY_NAME="server"
CLIENT_KEY_NAME="client"
GENBIN="generate-random-id"

####################################################################
#
# Health checks
#





hex2base()
{
  echo $1  | xxd -r -p | openssl base64
}

echo "\"control\" : [
  { \"id\" : \""$(hex2base $1)"\",
    \"port\" : $3,
    \"allowed\" : [
      { \"id\" : \""$(hex2base $2)"\",
        \"permissions\" : 15
      }
    ]
  }
],"

