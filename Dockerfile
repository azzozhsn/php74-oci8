FROM php:7.4-fpm

RUN mkdir /opt/oracle
    
ADD instantclient-basic-linux.zip /opt/oracle
ADD instantclient-sdk-linux.zip /opt/oracle

ENV LD_LIBRARY_PATH  /opt/oracle/instantclient_19_6:${LD_LIBRARY_PATH}

RUN apt-get update && apt-get install -y libldb-dev libmagickwand-dev \
        libldap2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        curl \
        unzip \
        libaio1 \
        wget \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) ldap gd calendar \
    && cd /opt/oracle \
    && unzip /opt/oracle/instantclient-basic-linux.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.zip -d /opt/oracle \
    && rm -rf /opt/oracle/*.zip \
    && echo 'instantclient,/opt/oracle/instantclient_19_6/' | pecl install oci8-2.2.0 \
    && docker-php-ext-enable oci8 \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/opt/oracle/instantclient_19_6,19.6 \
    && docker-php-ext-install pdo_oci pdo_mysql \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
