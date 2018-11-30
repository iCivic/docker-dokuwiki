FROM alpine:3.8

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="dokuwiki" \
  org.label-schema.description="DokuWiki based on Alpine Linux and Nginx" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-dokuwiki" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-dokuwiki" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

RUN apk --update --no-cache add \
    inotify-tools libgd nginx supervisor tar tzdata \
    php7 php7-cli php7-ctype php7-curl php7-fpm php7-gd php7-imagick php7-json php7-mbstring php7-openssl \
    php7-session php7-xml php7-zip php7-zlib \
  && rm -rf /var/cache/apk/* /var/www/* /tmp/*

# md5sum dokuwiki-$DOKUWIKI_VERSION.tar.gz
ENV DOKUWIKI_VERSION="2018-04-22a" \
  DOKUWIKI_MD5="30c41bddf1b1367de76cf6dd4c3d60e5"

RUN apk --update --no-cache add -t build-dependencies \
    gnupg wget \
  && cd /tmp \
  && wget -q "https://github.com/iCivic/dokuwiki/archive/dokuwiki-$DOKUWIKI_VERSION.tar.gz" \
  && echo "$DOKUWIKI_MD5  /tmp/dokuwiki-$DOKUWIKI_VERSION.tar.gz" | md5sum -c - | grep OK \
  && tar -zxvf "dokuwiki-$DOKUWIKI_VERSION.tar.gz" --strip 1 -C /var/www \
  && apk del build-dependencies \
  && rm -rf  /root/.gnupg /tmp/* /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
ADD assets /

RUN mkdir -p /var/log/supervisord \
  && chmod a+x /entrypoint.sh /usr/local/bin/* \
  && chown -R nginx. /var/lib/nginx /var/log/nginx /var/log/php7 /var/tmp/nginx /var/www

EXPOSE 80
WORKDIR "/var/www"
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

########################################
#
# build_date=`date +%Y%m%d`
# docker build --build-arg BUILD_DATE=$build_date --build-arg VCS_REF=f5bc32f6 --build-arg VERSION=$build_date -t idu/dokuwiki:latest .
# docker run -it --name alpine-3.8 -d alpine:3.8
# docker run -d -p 80:80 --name idu-dokuwiki -v $(pwd)/data:/data idu/dokuwiki:latest
