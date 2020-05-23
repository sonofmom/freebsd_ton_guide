#!/bin/sh
# This script will generate JSON control structure for local configuration file.
#
# Required params:
# BASE64 representation of SERVER key
# BASE64 representation of CLIENT key
# Control server port
#
# Example: mkcontrol.sh F20F63AFEF12926D0B0A023C8AA8217BDFF731E60EEE236D3D21C535E7F88F9C 0DF90396788B6CEC38585A980DD346A0FD5122710338B0B014A94059D0B08CB6 22222
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

