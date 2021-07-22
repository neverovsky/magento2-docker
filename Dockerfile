FROM php:7.4-fpm-alpine3.13
WORKDIR /var/www/magento2/
# COPY . /var/www/magento2
RUN apk update
RUN apk add \
    freetype-dev \
    libpng-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    icu-dev \
    nginx
RUN docker-php-ext-configure gd \
        --with-freetype=/usr/lib/ \
        --with-jpeg=/usr/lib/
RUN docker-php-ext-install \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    intl \
    soap \
    xsl \
    sockets \
    bcmath \
    zip

RUN docker-php-ext-install opcache
RUN { \
        echo 'opcache.memory_consumption=2048'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=64000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini


# mssql odbc for dabase connection
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.1-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.apk
RUN apk add --allow-untrusted msodbcsql17_17.5.2.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools_17.5.2.1-1_amd64.apk

RUN set -xe \
    && apk add --no-cache --virtual .persistent-deps freetds unixodbc \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS unixodbc-dev freetds-dev \
    && docker-php-source extract \
    && docker-php-ext-install pdo_dblib \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable --ini-name 30-sqlsrv.ini sqlsrv \
    && docker-php-ext-enable --ini-name 35-pdo_sqlsrv.ini pdo_sqlsrv \
    && docker-php-source delete \
    && apk del .build-deps

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# RUN composer update && composer install
# RUN chown -R www-data:www-data /var/www/
RUN chown -R www-data:www-data /var/lib/nginx/
RUN chown -R www-data:www-data /var/lib/nginx/logs/

# for cron work
RUN apk add --update busybox-suid

EXPOSE 80 443
COPY ./_docker/entrypoint.sh /etc/entrypoint.sh
ENTRYPOINT ["sh","/etc/entrypoint.sh"]
