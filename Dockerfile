FROM debian:bullseye-slim

ARG OPENSSL_VERSION="3.5.1"
ARG OPENSSL_SHA256="9a1472b5e2a019f69da7527f381b873e3287348f3ad91783f83fff4e091ea4a8"
ARG ENGINES_VERSION="3"
ARG OPENSSL_DIR="/usr/local/ssl"

RUN set -eux \
  \
  && apt-get update \
  && apt-get install wget build-essential unzip cmake git ca-certificates --no-install-recommends -y \
  \
  && mkdir -p /usr/local/src \
  \
  && cd /usr/local/src \
  && wget "https://github.com/openssl/openssl/archive/openssl-${OPENSSL_VERSION}.zip" -O "openssl-${OPENSSL_VERSION}.zip" \
  && echo "${OPENSSL_SHA256}" "openssl-${OPENSSL_VERSION}.zip" | sha256sum -c - \
  && unzip "openssl-${OPENSSL_VERSION}.zip" -d ./ \
  \
  && cd "openssl-openssl-${OPENSSL_VERSION}" \
  && ./config shared -d --prefix=${OPENSSL_DIR} --openssldir=${OPENSSL_DIR} \
  && make -j$(nproc) all \
  && make install \
  && mv /usr/bin/openssl /root/ \
  && ln -s ${OPENSSL_DIR}/bin/openssl /usr/bin/openssl \
  && export OPENSSL_LIB=$(if [ "${TARGETARCH}" = "arm64" ]; then echo "lib"; else echo "lib64"; fi) \
  && echo "${OPENSSL_DIR}/${OPENSSL_LIB}" >> /etc/ld.so.conf.d/ssl.conf \
  && ldconfig \
  \
  && cd /usr/local/src \
  && git clone https://github.com/gost-engine/engine \
  && cd engine \
  && git submodule update --init \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -DOPENSSL_ROOT_DIR="${OPENSSL_DIR}" \
    -DOPENSSL_LIBRARIES="${OPENSSL_DIR}/${OPENSSL_LIB}" .. \
    -DOPENSSL_ENGINES_DIR="${OPENSSL_DIR}/${OPENSSL_LIB}/engines-${ENGINES_VERSION}" \
    -DOPENSSL_CRYPTO_LIBRARY="${OPENSSL_DIR}/${OPENSSL_LIB}" \
  && cmake --build . --config Release \
  && cmake --build . --target install --config Release \
  && rm -rf /usr/local/src/engine \
  \
  && sed -i 's|openssl_conf =|# openssl_conf =|' "${OPENSSL_DIR}/openssl.cnf" \
  && sed -i '6i openssl_conf=openssl_def' "${OPENSSL_DIR}/openssl.cnf" \
  && echo "" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "# OpenSSL default section" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "[openssl_def]" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "engines = engine_section" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "# Engine section" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "[engine_section]" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "gost = gost_section" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "# Engine gost section" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "[gost_section]" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "engine_id = gost" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "dynamic_path = ${OPENSSL_DIR}/${OPENSSL_LIB}/engines-${ENGINES_VERSION}/gost.so" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "default_algorithms = ALL" >> "${OPENSSL_DIR}/openssl.cnf" \
  && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> "${OPENSSL_DIR}/openssl.cnf"
