#!/bin/bash

OPENSSL_VERSION=3.5.1
CURL_VERSION=8.15.0
STUNNEL_VERSION=5.75
NGINX_VERSION=1.29.0
OPENVPN_VERSION=2.6.14

docker push seshhekotikhin/openssl-gost:${OPENSSL_VERSION}
docker push seshhekotikhin/openssl-gost:latest
docker push seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-curl-${CURL_VERSION}
docker push seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-stunnel-${STUNNEL_VERSION}
docker push seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-nginx-${NGINX_VERSION}
docker push seshhekotikhin/openssl-gost:${OPENSSL_VERSION}-openvpn-${OPENVPN_VERSION}
