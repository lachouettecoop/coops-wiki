# Adapted from https://github.com/damoon/docker-dokuwiki/blob/master/Dockerfile
FROM alpine:3.6
MAINTAINER Ilya Stepanov <dev@ilyastepanov.com>

ENV DOKUWIKI_VERSION 2017-02-19b

RUN apk --no-cache add php7 php7-fpm php7-gd php7-session php7-xml php7-openssl nginx supervisor curl tar

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
        "todo https://github.com/leibler/dokuwiki-plugin-todo/ 02f3c00c0f158ebbfdaf99fbbcf47aafad131612" \
        "edittable https://github.com/cosmocode/edittable/ 2017-06-07" \
        "encryptedpasswords https://github.com/ssahara/dw-plugin-encryptedpasswords/ 172e3564af45333108caf0e8d239b354b1acedaa" \
        "move https://github.com/michitux/dokuwiki-plugin-move/ aca0c0cdcd70906f02bd35532f4b036a574fd484" \
        "wrap https://github.com/selfthinker/dokuwiki_plugin_wrap/ d601d9a5ca60075420f012d0c97e8a3b5600cd16" \
        "gallery https://github.com/splitbrain/dokuwiki-plugin-gallery/ 3714020c63c650dc610b98ed20f79c5742fc15d3" \
        "smtp https://github.com/splitbrain/dokuwiki-plugin-smtp 2017-02-08" \
    ; do \
        name=`echo $plugin|cut -d" " -f1`; \
        url=`echo $plugin|cut -d" " -f2`; \
        version=`echo $plugin|cut -d" " -f3`; \
        mkdir -p  /var/www/lib/plugins/$name; \
        echo "Download plugin $name, version $version from $url"; \
        (cd /var/www/lib/plugins/$name/ && curl -s -L "$url/archive/${version}.tar.gz" | tar xz --strip 1); \
    done

