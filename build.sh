#!/bin/bash

OPENSSL_VERSION=3.5.1
OPENSSL_SHA256=9a1472b5e2a019f69da7527f381b873e3287348f3ad91783f83fff4e091ea4a8
ENGINES_VERSION=3
CURL_VERSION=8.15.0
CURL_SHA256=d85cfc79dc505ff800cb1d321a320183035011fa08cb301356425d86be8fc53c
STUNNEL_VERSION=5.75
STUNNEL_SHA256=0c1ef0ed85240974dccb94fe74fb92d6383474c7c0d10e8796d1f781a3ba5683
NGINX_VERSION=1.29.0
NGINX_SHA256=109754dfe8e5169a7a0cf0db6718e7da2db495753308f933f161e525a579a664

docker build --platform linux/arm64 --build-arg OPENSSL_VERSION=${OPENSSL_VERSION} --build-arg OPENSSL_SHA256=${OPENSSL_SHA256} --build-arg ENGINES_VERSION=${ENGINES_VERSION} -f Dockerfile -t seshhekotikhin/openssl-gost:arm-${OPENSSL_VERSION} .
docker build --platform linux/amd64 --build-arg OPENSSL_VERSION=${OPENSSL_VERSION} --build-arg OPENSSL_SHA256=${OPENSSL_SHA256} --build-arg ENGINES_VERSION=${ENGINES_VERSION} -f Dockerfile -t seshhekotikhin/openssl-gost:amd-${OPENSSL_VERSION} .
# docker manifest create --amend seshhekotikhin/openssl-gost:${OPENSSL_VERSION} seshhekotikhin/openssl-gost:amd-${OPENSSL_VERSION} seshhekotikhin/openssl-gost:arm-${OPENSSL_VERSION}
# if ! docker run --rm seshhekotikhin/openssl-gost:${OPENSSL_VERSION} openssl ciphers | grep GOST &> /dev/null; then
#   echo 'GOST ciphers not found'
#   exit -1
# fi

# docker build --build-arg OPENSSL_VERSION=${OPENSSL_VERSION} --build-arg CURL_VERSION=${CURL_VERSION} --build-arg CURL_SHA256=${CURL_SHA256} -f Dockerfile.curl -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-curl-${CURL_VERSION} .
# if ! docker run --rm seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-curl-${CURL_VERSION} curl -k https://alpha.demo.nbki.ru &> /dev/null; then
#   echo 'GOST curl working improperly'
#   exit -1
# fi

# docker build --build-arg OPENSSL_VERSION=${OPENSSL_VERSION} --build-arg STUNNEL_VERSION=${STUNNEL_VERSION} --build-arg STUNNEL_SHA256=${STUNNEL_SHA256} -f Dockerfile.stunnel -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-stunnel-${STUNNEL_VERSION} .

# docker build --build-arg OPENSSL_VERSION=${OPENSSL_VERSION} --build-arg OPENSSL_SHA256=${OPENSSL_SHA256} --build-arg ENGINES_VERSION=${ENGINES_VERSION} --build-arg CURL_VERSION=${CURL_VERSION} --build-arg CURL_SHA256=${CURL_SHA256} --build-arg NGINX_VERSION=${NGINX_VERSION} --build-arg NGINX_SHA256=${NGINX_SHA256} -f Dockerfile.nginx -t seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-nginx-${NGINX_VERSION} .
# if ! docker run --rm seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-nginx-${NGINX_VERSION} nginx -t &> /dev/null; then
#   echo 'GOST nginx working improperly'
#   exit -1
# fi
