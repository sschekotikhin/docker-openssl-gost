# Docker images with OpenSSL 3.x, GOST engine, cURL, nginx and stunnel

This image was built to have ability to connect to servers with GOST SSL certificates; encrypt, decrypt, hash messages with GOST algorithms. It built with fresh versions of OpenSSL (3.5.1), nginx (1.29), cURL (8.15.0) and stunnel (5.75).

To verify that OpenSSL contains GOST ciphers, run `docker run --rm seshhekotikhin/openssl-gost:latest openssl ciphers`. You will see next output:
```
ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES256-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:RSA-PSK-AES256-GCM-SHA384:DHE-PSK-AES256-GCM-SHA384:RSA-PSK-CHACHA20-POLY1305:DHE-PSK-CHACHA20-POLY1305:ECDHE-PSK-CHACHA20-POLY1305:AES256-GCM-SHA384:PSK-AES256-GCM-SHA384:PSK-CHACHA20-POLY1305:RSA-PSK-AES128-GCM-SHA256:DHE-PSK-AES128-GCM-SHA256:AES128-GCM-SHA256:PSK-AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:ECDHE-PSK-AES256-CBC-SHA384:ECDHE-PSK-AES256-CBC-SHA:SRP-RSA-AES-256-CBC-SHA:SRP-AES-256-CBC-SHA:RSA-PSK-AES256-CBC-SHA384:DHE-PSK-AES256-CBC-SHA384:RSA-PSK-AES256-CBC-SHA:DHE-PSK-AES256-CBC-SHA:GOST2012-GOST8912-GOST8912:GOST2001-GOST89-GOST89:AES256-SHA:PSK-AES256-CBC-SHA384:PSK-AES256-CBC-SHA:ECDHE-PSK-AES128-CBC-SHA256:ECDHE-PSK-AES128-CBC-SHA:SRP-RSA-AES-128-CBC-SHA:SRP-AES-128-CBC-SHA:RSA-PSK-AES128-CBC-SHA256:DHE-PSK-AES128-CBC-SHA256:RSA-PSK-AES128-CBC-SHA:DHE-PSK-AES128-CBC-SHA:AES128-SHA:PSK-AES128-CBC-SHA256:PSK-AES128-CBC-SHA
```

The key part of output:
```
GOST2012-GOST8912-GOST8912
GOST2001-GOST89-GOST89
```

All images build with [OpenSSL GOST engine](https://github.com/gost-engine/engine). If you want to build your image, just check [the official instructure](https://github.com/gost-engine/engine/blob/master/INSTALL.md).

## Docker images

There are few images on dockerhub:
- `seshhekotikhin/openssl-gost:latest` or `seshhekotikhin/openssl-gost:3.5.1` - GOST OpenSSL.
- `seshhekotikhin/openssl-gost:3.5.1-curl-8.15.0` - GOST OpenSSL with cURL.
- `seshhekotikhin/openssl-gost:3.5.1-stunnel-5.75` - GOST OpenSSL with stunnel.
- `seshhekotikhin/openssl-gost:3.5.1-nginx-1.29.0` - GOST OpenSSL with nginx and cURL.

## Usage examples

To show certificates chain of host with GOST:
```bash
docker run --rm seshhekotikhin/openssl-gost:latest openssl s_client -connect alpha.demo.nbki.ru:443
```

To generate private key and certificate:
```bash
docker run --volume $(pwd):/certs --rm -i seshhekotikhin/openssl-gost:latest openssl req -x509 -newkey gost2001 -pkeyopt paramset:A -nodes -keyout /certs/key.pem -out certs/cert.pem
```

To get info from certificate:
```bash
docker run --volume $(pwd):/certs --rm seshhekotikhin/openssl-gost:latest openssl x509 -text -in /certs/cert.pem -noout
```

To sign file with electronic signature by GOST using public certificate (-signer cert.pem), private key (-inkey key.pem), with opaque signing (-nodetach), DER as output format without including certificate and attributes (-nocerts -noattr):
```bash
docker run --volume $(pwd):/certs --rm seshhekotikhin/openssl-gost:latest openssl cms -sign -signer /certs/cert.pem -inkey /certs/key.pem -binary -in /certs/text.txt -nodetach -outform DER -nocerts -noattr -out /certs/signed.sgn
```

To extract data (verify) from signed file (DER-format) using public certificate (-certfile cert.pem) issued by CA (-CAfile cert.pem) (the same because cert.pem is self-signed):
```bash
docker run --volume $(pwd):/certs --rm seshhekotikhin/openssl-gost:latest openssl cms -verify -in /certs/signed.sgn -certfile /certs/cert.pem -CAfile /certs/cert.pem -inform der -out /certs/data.txt
```

More examples with GOST can be found here: https://github.com/gost-engine/engine/blob/master/README.gost

## Issues with certification authority

If you got error like this: `SSL certificate problem: unable to get local issuer certificate`, there are two options to solve it:
1. Disable certificate verification - `curl -k` or `openssl cms -noverify` (unsafe and not recommended).
2. Find and install root certificates.

If you want to use root certificates:
- Download it (for example, [CryptoPRO CA](http://cpca.cryptopro.ru/cacer.p7b)).
- Convert it, if it i not in PEM format - `openssl pkcs7 -inform DER -outform PEM -in cacer.p7b -print_certs > crypto_pro_ca_bundle.crt`.
- Copy to CA store `cp crypto_pro_ca_bundle.crt /usr/local/share/ca-certificates && update-ca-certificates` or specify within request `curl --cacert crypto_pro_ca_bundle.crt ...`.

## Usage in other Dockerfiles

You can copy compiled tools to your image from next directories:
- `/usr/local/ssl` - OpenSSL with GOST.
- `/usr/local/curl` - cURL with OpenSSL GOST.
- `/usr/local/stunnel` - stunnel with OpenSSL GOST.

## Remarks

This repo refers to https://github.com/rnixik/docker-openssl-gost and https://github.com/gost-engine/engine, thanks.
