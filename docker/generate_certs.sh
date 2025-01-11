#!/bin/bash

# Load environment variables
source .env

# Create certificates directory
mkdir -p certs
cd certs

echo "Generating SSL certificates..."

# Generate CA key and certificate
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 \
    -key ca-key.pem \
    -out ca.pem \
    -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_LOCALITY}/O=${SSL_ORGANIZATION}/OU=${SSL_ORGANIZATIONAL_UNIT}/CN=${SSL_COMMON_NAME}"

# Generate server key and certificate
openssl req -newkey rsa:2048 -nodes -days 365000 \
    -keyout server-key.pem \
    -out server-req.pem \
    -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_LOCALITY}/O=${SSL_ORGANIZATION}/OU=${SSL_ORGANIZATIONAL_UNIT}/CN=${SSL_COMMON_NAME}"
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 365000 \
    -CA ca.pem -CAkey ca-key.pem -set_serial 01 \
    -out server-cert.pem

# Set correct permissions
chmod 600 server-key.pem ca-key.pem

echo "SSL certificates generated successfully!"
echo "Location: $(pwd)"
echo "Files created:"
ls -l

cd .. 