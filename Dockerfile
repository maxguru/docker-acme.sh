FROM alpine:3.4

RUN apk add --no-cache busybox curl tar openssl netcat-openbsd

# Internal
ENV ACME_VERSION 2.6.6
ENV ACME_DIR /acme.sh
ENV LE_WORKING_DIR $ACME_DIR
ENV INSTALL_SRC https://raw.githubusercontent.com/Neilpang/acme.sh/${ACME_VERSION}/acme.sh
ENV TEMP_FILE /tmp/acme.sh

# External
ENV CERT_DIR /certs
ENV ACCOUNT_DIR /account

RUN mkdir -p ${CERT_DIR} ${ACCOUNT_DIR} \
    && curl ${INSTALL_SRC} -o ${TEMP_FILE} \
    && INSTALLONLINE=1 BRANCH=${ACME_VERSION} sh ${TEMP_FILE} \
       --install \
       --home ${ACME_DIR} \
       --certhome ${CERT_DIR} \
       --accountkey ${ACCOUNT_DIR}/account.key \
       --useragent "acme.sh in docker" \
    && ln -s ${ACME_DIR}/acme.sh /usr/local/bin \
    && rm ${TEMP_FILE}

VOLUME $CERT_DIR
VOLUME $ACCOUNT_DIR

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crond", "-f"]
