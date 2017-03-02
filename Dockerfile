FROM alpine:3.5
MAINTAINER Ilya Stepanov <dev@ilyastepanov.com>

RUN apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip || \
	(sed -i -e 's/dl-cdn/dl-1/g' /etc/apk/repositories && apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip) || \
	(sed -i -e 's/dl-1/dl-2/g' /etc/apk/repositories && apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip) || \
	(sed -i -e 's/dl-2/dl-3/g' /etc/apk/repositories && apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip) || \
	(sed -i -e 's/dl-3/dl-4/g' /etc/apk/repositories && apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip) || \
	(sed -i -e 's/dl-4/dl-5/g' /etc/apk/repositories && apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip) || \
	(sed -i -e 's/dl-5/dl-6/g' /etc/apk/repositories && apk --no-cache add \
    php7 php7-fpm php7-gd php7-session php7-xml supervisor curl tar unzip)

RUN mkdir -p /var/www && \
    cd /var/www && \
    curl -O -L "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz" && \
    tar -xzf "dokuwiki-stable.tgz" --strip 1 && \
rm "dokuwiki-stable.tgz"

RUN cd /var/www/lib/plugins/ && \
	curl -O -L "https://github.com/leibler/dokuwiki-plugin-todo/archive/stable.zip" && \
    unzip stable.zip -d /var/www/lib/plugins/ && \
    mv /var/www/lib/plugins/dokuwiki-plugin-todo-stable /var/www/lib/plugins/todo && \
    rm -rf stable.zip    

RUN cd /var/www/lib/plugins/ && \
	curl -O -L "https://github.com/cosmocode/edittable/archive/master.zip" && \
    unzip master.zip -d /var/www/lib/plugins/ && \
    mv /var/www/lib/plugins/edittable-master /var/www/lib/plugins/edittable && \
    rm -rf master.zip    

RUN cd /var/www/lib/plugins/ && \
	curl -O -L "https://github.com/ssahara/dw-plugin-encryptedpasswords/archive/master.zip" && \
    unzip master.zip -d /var/www/lib/plugins/ && \
    mv /var/www/lib/plugins/dw-plugin-encryptedpasswords-master /var/www/lib/plugins/encryptedpasswords && \
    rm -rf master.zip    

RUN cd /var/www/lib/plugins/ && \
	curl -O -L "https://github.com/michitux/dokuwiki-plugin-move/zipball/master" && \
    unzip master -d /var/www/lib/plugins/ && \
    rm -rf master    

RUN cd /var/www/lib/plugins/ && \
	curl -O -L "https://github.com/selfthinker/dokuwiki_plugin_wrap/archive/stable.zip" && \
    unzip stable.zip -d /var/www/lib/plugins/ && \
    mv /var/www/lib/plugins/dokuwiki_plugin_wrap-stable /var/www/lib/plugins/wrap && \
    rm -rf stable.zip    

RUN cd /var/www/lib/plugins/ && \
	curl -O -L "https://github.com/splitbrain/dokuwiki-plugin-gallery/zipball/master" && \
    unzip master -d /var/www/lib/plugins/ && \
    rm -rf master

RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php7/php-fpm.ini && \
    sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" /etc/php7/php-fpm.conf && \
    sed -i -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm7.sock|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.owner\s*=\s*|listen.owner = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.group\s*=\s*|listen.group = |g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s|;listen\.mode\s*=\s*|listen.mode = |g" /etc/php7/php-fpm.d/www.conf

EXPOSE 80

CMD /start.sh
