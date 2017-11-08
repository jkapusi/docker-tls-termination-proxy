#!/bin/bash

set -e

export CERT_PATH=${CERT_PATH:-"/cert.pem"}

if [ ! -f "${CERT_PATH}" ]; then
    echo "Certificate file '$CERT_PATH' not found. Make sure it is mounted as a volume when starting the container."
    exit 1
fi

# Environmenat variables and defaults for the configuration
export HTTPS_UPSTREAM_SERVER_ADDRESS=${HTTPS_UPSTREAM_SERVER_ADDRESS:-"upstream"}
export HTTPS_UPSTREAM_SERVER_PORT=${HTTPS_UPSTREAM_SERVER_PORT:-80}
export CIPHERS=${CIPHERS:-"ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:!aNULL:!MD5:!DSS:!3DES:!RSA"}

# Prepare configuration file
config=/etc/pound/pound.cfg

echo "Resolving placeholders in configuration file: $config"

perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' $config

echo "Resulting configuration: (line numbers prepended)"
awk '{printf "%d\t | %s\n", NR, $0}' < $config

# Start pound
exec /usr/sbin/pound \
     -f $config \
     -p /var/run/pound/pound.pid
