FROM centos:7
MAINTAINER madebymode

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://repo.ius.io/ius-release-el7.rpm
# Update and install latest packages and prerequisites
RUN yum update -y \
    && yum install -y --nogpgcheck --setopt=tsflags=nodocs \
        php74-cli \
        php74-common \
        php74-fpm \
        php74-gd \
        php74-mbstring \
        php74-mysqlnd \
        php74-xml \
        php74-json \
        php74-intl \
        php74-soap \
        zip \
        unzip \
        sudo \
        git \
        mysql \
        rsync \ 
        wget \
        bash-completion \
    && yum clean all && yum history new

RUN sed -e 's/127.0.0.1:9000/9000/' \
        -e '/allowed_clients/d' \
        -e '/catch_workers_output/s/^;//' \
        -e '/error_log/d' \
        -i /etc/php-fpm.d/www.conf

#fixes  ERROR: Unable to create the PID file (/run/php-fpm/php-fpm.pid).: No such file or directory (2)
RUN sed -e '/^pid/s//;pid/' -i /etc/php-fpm.conf
#fixes ERROR: failed to open error_log (/var/log/php-fpm/error.log): Permission denied (13), which running php-fpm as docker user
RUN sed -e '/^error_log\s\=\s\/var\/log\/php-fpm\/error.log/s//error_log = \/dev\/stderr/' -i /etc/php-fpm.conf


#composer 1.10
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.17 --install-dir=/usr/local/bin --filename=composer
#composer 2
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2

#wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \ 
    && chmod +x wp-cli.phar \ 
    && mv wp-cli.phar /usr/local/bin/wp
    

RUN echo 'Creating notroot docker user and group from host' && \
    groupadd -g $HOST_USER_GID docker && \
    useradd -lm -u $HOST_USER_UID -g $HOST_USER_GID docker

#  Add new user docker user to php-fpm group
RUN usermod -a -G php-fpm docker
# give docker user sudo access
RUN usermod -aG wheel docker
# give docker user access to /dev/stdout and /dev/stderror
RUN usermod -aG tty docker

# Ensure sudo group users are not
# asked for a password when using
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

CMD ["/usr/sbin/php-fpm", "--nodaemonize"]

EXPOSE 9000
