FROM php:7.3-apache

LABEL MAINTAINER="Tom Gross <itconsense@gmail.com>" 

RUN usermod -u 1000 www-data && usermod -G staff www-data

RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libpq-dev zip unzip libzip-dev sudo wget sqlite3 libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd  \
  && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
  && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
  && docker-php-ext-configure zip --with-libzip \
  &&  yes | pecl install igbinary redis \
  && docker-php-ext-install pdo \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install mysqli \
  && docker-php-ext-install pgsql \
  && docker-php-ext-install pdo_pgsql \
  && docker-php-ext-install pdo_sqlite \
  && docker-php-ext-install gd \
  && docker-php-ext-install mbstring \
  && docker-php-ext-install opcache \
  && docker-php-ext-install zip \
  && docker-php-ext-install calendar \
  && docker-php-ext-enable igbinary \
  && docker-php-ext-enable redis \ { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.load_comments=1'; \
} >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini 


RUN a2enmod rewrite
# to see live logs we do : docker logs -f [CONTAINER ID]
# without the following line we get "AH00558: apache2: Could not reliably determine the server's fully qualified domain name"
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# autorise .htaccess files
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

VOLUME /var/www/html

ENV TAO_VERSION 3.2.0-RC2_build
ENV TAO_SHA1 2e8f42f4ad07444c25b4b50a539aefdd83a5b5d1
ENV MATHJAX_VERSION 2.7.5

RUN curl -o tao.zip -SL http://releases.taotesting.com/TAO_${TAO_VERSION}.zip \
  && echo "$TAO_SHA1 *tao.zip" | sha1sum -c - \
  && unzip -qq tao.zip -d /usr/src \
  && mv /usr/src/TAO_${TAO_VERSION} /usr/src/tao \
  && rm tao.zip \
  && chown -R www-data:www-data /usr/src/tao \
  && curl -o MathJax.zip -SL https://github.com/mathjax/MathJax/archive/${MATHJAX_VERSION}.zip \
  && unzip -qq MathJax.zip -d /usr/src/tao/taoQtiItem/views/js \
  && rmdir /usr/src/tao/taoQtiItem/views/js/mathjax \
  && mv /usr/src/tao/taoQtiItem/views/js/MathJax-${MATHJAX_VERSION}/ /usr/src/tao/taoQtiItem/views/js/mathjax \
  && rm -rf MathJax.zip /usr/src/tao/taoQtiItem/views/js/mathjax/docs \
  && rm -rf /usr/src/tao/taoQtiItem/views/js/mathjax/test \
  && rm -rf /usr/src/tao/taoQtiItem/views/js/mathjax/unpacked \
  && rm -rf /usr/src/tao/taoQtiItem/views/js/mathjax/fonts/HTML-CSS/TeX/otf/ \
  && rm -rf /usr/src/tao/taoQtiItem/views/js/mathjax/fonts/HTML-CSS/TeX/svg  \
  && find /usr/src/tao/taoQtiItem/views/js/mathjax/config ! -name 'TeX-AMS-MML_HTMLorMML-full.js' -type f -delete

COPY docker-entrypoint.sh /entrypoint.sh
COPY php.ini /usr/local/etc/php/

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
