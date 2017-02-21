FROM php:7-fpm-alpine
MAINTAINER Sascha Egerer <s.egerer@syzygy.de>

EXPOSE 22 80 443 843 22280

ENTRYPOINT ["/Scripts/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

ENV SOURCE_DIR=/opt/phabricator
ENV PHABRICATOR_DIR="$SOURCE_DIR/phabricator"

# Install PHP extensions
RUN apk --no-cache add --update nginx libcurl curl-dev git subversion curl imagemagick supervisor nodejs py-pygments sudo mariadb-client postfix freetype freetype-dev libxml2 libpng-dev libjpeg-turbo-dev curl openssh 

COPY Files/Scripts /Scripts
COPY Files/custom.php.ini /usr/local/etc/php/conf.d/z_phabricator-custom.ini
COPY Files/nginx.conf /etc/nginx/nginx.conf
COPY Files/custom.my.cnf /etc/mysql/conf.d/z_phabricator-custom.cnf
COPY Files/sshd_config.phabricator /etc/ssh/sshd_config
COPY Files/phabricator-ssh-hook.sh /etc/ssh/phabricator-ssh-hook.sh
COPY Files/supervisor.conf /etc/supervisor/supervisord.conf
COPY Files/supervisor.conf.d/* /etc/supervisor/conf.d/

RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr && \
    docker-php-ext-install gd mysqli mbstring iconv curl pcntl fileinfo json posix ctype zip sockets opcache && \
    mkdir -p /opt/phabricator && \
    adduser -D -G www-data -s /bin/bash -h /opt/phabricator git && \
    touch /var/log/aphlict.log && \
    chown git:www-data /var/log/aphlict.log && \
    npm install -g ws && \
    mkdir /var/run/sshd && \
    chmod +x /Scripts/*.sh && \
    chmod 550 /etc/ssh/phabricator-ssh-hook.sh && \
    chown git:root /etc/ssh/phabricator-ssh-hook.sh && \
    echo "git ALL=(git) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/svnserve" >> /etc/sudoers && \
    cd /opt/phabricator && \
    git clone git://github.com/facebook/libphutil.git && \
    git clone git://github.com/facebook/arcanist.git && \
    git clone git://github.com/facebook/phabricator.git && \
    git clone git://github.com/PHPOffice/PHPExcel.git
