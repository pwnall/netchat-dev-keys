#!/bin/sh
# The script used to generate the development VM keys.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# OpenSSL state.
mkdir -p tmp
echo "01" > tmp/serial
echo -n "" > tmp/index.txt

# CA key and self-signed certificate.
openssl req -config script/openssl.cnf -x509 -nodes -days 3650 -newkey rsa:2048 \
    -out _ca.cer -outform PEM -keyout _ca.pem -keyform PEM \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=MIT CSAIL/OU=NetChat Dev Keys/CN=Dev CA"


# Web server key and certificate signing request.
openssl req -nodes -newkey rsa:2048 -sha1 \
    -out web.csr -outform PEM -keyout web.pem -keyform PEM \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=MIT CSAIL/OU=NetChat Dev Keys/CN=netchat.local"

# Web server certificate.
openssl ca -config script/openssl.cnf -batch -cert _ca.cer -keyfile _ca.pem \
    -md sha1 -days 3650 -in web.csr -out web.cer -outdir tmp -notext
rm web.csr
cat web.cer _ca.cer > web.crt
rm web.cer


# Queue server key and certificate signing request.
openssl req -nodes -newkey rsa:2048 -sha1 \
    -out queue.csr -outform PEM -keyout queue.pem -keyform PEM \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=MIT CSAIL/OU=NetChat Dev Keys/CN=netqueue.local:8443"

# Queue server certificate.
openssl ca -config script/openssl.cnf -batch -cert _ca.cer -keyfile _ca.pem \
    -md sha1 -days 3650 -in queue.csr -out queue.cer -outdir tmp -notext
rm queue.csr
cat queue.cer _ca.cer > queue.crt
rm queue.cer


# Chat server key and certificate signing request.
openssl req -nodes -newkey rsa:2048 -sha1 \
    -out chat.csr -outform PEM -keyout chat.pem -keyform PEM \
    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=MIT CSAIL/OU=NetChat Dev Keys/CN=netchat.local:9443"

# Chat server certificate.
openssl ca -config script/openssl.cnf -batch -cert _ca.cer -keyfile _ca.pem \
    -md sha1 -days 3650 -in chat.csr -out chat.cer -outdir tmp -notext
rm chat.csr
cat chat.cer _ca.cer > chat.crt
rm chat.cer

