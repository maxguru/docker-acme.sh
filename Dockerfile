FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -yq  --no-install-recommends --no-install-suggests ca-certificates curl tar openssl netcat-openbsd cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Internal
ENV ACME_DIR /acme.sh
ENV LE_WORKING_DIR $ACME_DIR
ENV TEMP_DIR /tmp/acme.sh

# External
ENV CERT_DIR /certs
ENV ACCOUNT_DIR /account

RUN mkdir -p ${CERT_DIR} ${ACCOUNT_DIR} ${TEMP_DIR} \
    && curl -s -L https://github.com/Neilpang/acme.sh/archive/master.tar.gz | tar xzf - --strip 1 -C ${TEMP_DIR} \
    && cd ${TEMP_DIR} \
    && ./acme.sh \
       --install \
       --home ${ACME_DIR} \
       --cert-home ${CERT_DIR} \
       --accountkey ${ACCOUNT_DIR}/account.key \
       --useragent "acme.sh in docker" \
       --auto-upgrade 1 \
    && ln -s ${ACME_DIR}/acme.sh /usr/local/bin \
    && rm -rf ${TEMP_DIR}

VOLUME $CERT_DIR
VOLUME $ACCOUNT_DIR

COPY docker-entrypoint.sh /

# workaround for https://github.com/dodrio/docker-acme.sh/issues/3
RUN crontab -l | sed "s/ --home \"\/acme.sh\"//" | crontab -

# fix for missing environment variables
RUN crontab -l | sed "s/\"\/acme.sh\"\/acme.sh/. \$HOME\/.profile; \"\/acme.sh\"\/acme.sh/" | crontab -

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cron", "-f"]
