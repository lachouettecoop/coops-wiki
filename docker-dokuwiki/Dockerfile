# Adapted from https://github.com/damoon/docker-dokuwiki/blob/master/Dockerfile
FROM alpine:3.6
MAINTAINER Ilya Stepanov <dev@ilyastepanov.com>

ENV DOKUWIKI_VERSION 2020-07-29

RUN apk --no-cache add php7 php7-fpm php7-gd php7-json php7-session php7-xml php7-dom php7-zlib php7-openssl nginx supervisor curl tar

RUN mkdir -p /run/nginx

RUN mkdir -p /run/nginx && \
    mkdir -p /var/www && \
    cd /var/www && \
    (curl -s -L "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" | tar xz --strip 1)

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY start.sh /start.sh

RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php7/php-fpm.ini && \
    sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \
    sed -i -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm7.sock|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.owner\s*=\s*|listen.owner = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.group\s*=\s*|listen.group = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.mode\s*=\s*|listen.mode = |g" /etc/php7/php-fpm.d/www.conf && \
    chmod +x /start.sh

VOLUME ["/var/dokuwiki-storage"]

EXPOSE 80

CMD /start.sh

# Plugins Installation
RUN for plugin in \
        "todo https://github.com/leibler/dokuwiki-plugin-todo/ 2449f39441f013902e2d9f2bc5d5da6b92cbaf95" \
        "edittable https://github.com/cosmocode/edittable/ 2020-08-12" \
        "encryptedpasswords https://github.com/ssahara/dw-plugin-encryptedpasswords/ 120f2532d9559b2a32785b1f09fb99cb1a5201cc" \
        "move https://github.com/michitux/dokuwiki-plugin-move/ efb8e0ee8d595fc40ba34c53ace846214affbc2f" \
        "wrap https://github.com/selfthinker/dokuwiki_plugin_wrap/ 9ad5fdffdf97087aef0399a82b24053bf58e4298" \
        "gallery https://github.com/splitbrain/dokuwiki-plugin-gallery/ bdb91e7ef5d94b2c9447f2860b9b0efe4d5dc5a7" \
        "smtp https://github.com/splitbrain/dokuwiki-plugin-smtp/ 2020-02-24" \
        "backup https://github.com/tatewake/dokuwiki-plugin-backup/ 297168803cb0903f2e3cdc066a59597d9c0559ae" \
	"ckgedit https://github.com/turnermm/ckgedit 30a6d4f9b3b98ec0c7b247bcac173da6d2c184db" \
	"authsaml https://github.com/pitbulk/dokuwiki-saml 6161c7338d5464fdc8b635e6b96a88615c9ee287" \
    ; do \
        name=`echo $plugin|cut -d" " -f1`; \
        url=`echo $plugin|cut -d" " -f2`; \
        version=`echo $plugin|cut -d" " -f3`; \
        mkdir -p  /var/www/lib/plugins/$name; \
        echo "Download plugin $name, version $version from $url"; \
        (cd /var/www/lib/plugins/$name/ && curl -s -L "$url/archive/${version}.tar.gz" | tar xz --strip 1); \
    done

# Install SimpleSamlPHP needed by authsaml plugin
RUN mkdir -p /var/www/simplesamlphp && \
	cd /var/www/simplesamlphp && \
	curl -s -L "https://github.com/simplesamlphp/simplesamlphp/releases/download/v1.18.8/simplesamlphp-1.18.8.tar.gz" | tar xz --strip 1
