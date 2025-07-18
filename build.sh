#!/bin/bash

OPENSSL_VERSION=3.5.1
CURL_VERSION=8.15.0
STUNNEL_VERSION=5.75
NGINX_VERSION=1.29.0

docker build --platform linux/arm64,linux/amd64 -f Dockerfile -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION} .
if ! docker run --rm seshhekotikhin/openssl-gost:${OPENSSL_VERSION} openssl ciphers | grep GOST &> /dev/null; then
  echo 'GOST ciphers not found'
  exit -1
fi
docker tag seshhekotikhin/openssl-gost:${OPENSSL_VERSION} seshhekotikhin/openssl-gost:latest

docker build --platform linux/arm64,linux/amd64 -f Dockerfile.curl -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-curl-${CURL_VERSION} .
if ! docker run --rm seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-curl-${CURL_VERSION} curl -k https://alpha.demo.nbki.ru &> /dev/null; then
  echo 'GOST curl working improperly'
  exit -1
fi

docker build --platform linux/arm64,linux/amd64 -f Dockerfile.stunnel -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-stunnel-${STUNNEL_VERSION} .

docker build --platform linux/arm64,linux/amd64 -f Dockerfile.nginx -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-nginx-${NGINX_VERSION} .
if ! docker run --rm seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-nginx-${NGINX_VERSION} nginx -t &> /dev/null; then
  echo 'GOST nginx working improperly'
  exit -1
fi
