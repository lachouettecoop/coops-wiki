#!/bin/sh

set -e

cd /var/www && \
curl -O -L "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz" && \
tar -xzf dokuwiki-stable.tgz --strip 1 && \
rm -rf dokuwiki-stable.tgz

curl -O -L "https://github.com/leibler/dokuwiki-plugin-todo/archive/stable.zip" && \
unzip stable.zip -d /var/www/lib/plugins/ && \
mv -f /var/www/lib/plugins/dokuwiki-plugin-todo-stable /var/www/lib/plugins/todo && \
rm -rf stable.zip    

curl -O -L "https://github.com/cosmocode/edittable/archive/master.zip" && \
unzip master.zip -d /var/www/lib/plugins/ && \
mv -f /var/www/lib/plugins/edittable-master /var/www/lib/plugins/edittable && \
rm -rf master.zip    

curl -O -L "https://github.com/ssahara/dw-plugin-encryptedpasswords/archive/master.zip" && \
unzip master.zip -d /var/www/lib/plugins/ && \
mv -f /var/www/lib/plugins/dw-plugin-encryptedpasswords-master /var/www/lib/plugins/encryptedpasswords && \
rm -rf master.zip    

curl -O -L "https://github.com/michitux/dokuwiki-plugin-move/zipball/master" && \
unzip master -d /var/www/lib/plugins/ && \
mv -f /var/www/lib/plugins/michitux* /var/www/lib/plugins/move
rm -rf master    

curl -O -L "https://github.com/selfthinker/dokuwiki_plugin_wrap/archive/stable.zip" && \
unzip stable.zip -d /var/www/lib/plugins/ && \
mv -f /var/www/lib/plugins/dokuwiki_plugin_wrap-stable /var/www/lib/plugins/wrap && \
rm -rf stable.zip    

curl -O -L "https://github.com/splitbrain/dokuwiki-plugin-gallery/zipball/master" && \
unzip master -d /var/www/lib/plugins/ && \
mv -f /var/www/lib/plugins/splitbrain* /var/www/lib/plugins/gallery
rm -rf master

chown -R nobody /var/www

su -s /bin/sh nobody -c 'php7 /var/www/bin/indexer.php -c'

exec /usr/bin/supervisord -c /etc/supervisord.conf
