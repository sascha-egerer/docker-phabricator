FROM php:7.0-fpm
MAINTAINER Sascha Egerer <s.egerer@syzygy.de>

EXPOSE 22 80 443 843

ENTRYPOINT ["/Scripts/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

ENV SOURCE_DIR=/opt/phabricator
ENV PHABRICATOR_DIR="$SOURCE_DIR/phabricator"

# Install PHP extensions
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y nginx git subversion curl imagemagick supervisor nodejs cron python-pygments sudo mariadb-client postfix libfreetype6-dev libxml2-dev libpng-dev libjpeg-dev libcurl4-gnutls-dev openssh-server npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
    useradd -G www-data git && \
    touch /var/log/aphlict.log && \
    chown git:www-data /var/log/aphlict.log && \
    npm install -g ws && \
    mkdir /var/run/sshd && \
    chmod +x /Scripts/*.sh /etc/ssh/phabricator-ssh-hook.sh && \
    mkdir /opt/phabricator && \
    cd /opt/phabricator && \
    git clone git://github.com/facebook/libphutil.git && \
    git clone git://github.com/facebook/arcanist.git && \
    git clone git://github.com/facebook/phabricator.git && \
    git clone git://github.com/PHPOffice/PHPExcel.git
