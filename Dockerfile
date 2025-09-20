ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli-alpine

# define variables
ARG BUILD_ENV
ARG APP_PATH="/app"
ENV APP_PATH=${APP_PATH}

ARG USER="dev"
ARG USER_ID=1000
ARG GROUP_ID=1000

# add packages
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    g++ \
    linux-headers \
    icu-dev \
    libxml2-dev \
    oniguruma-dev \
    libzip-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libxslt-dev \
    bzip2-dev \
    zlib-dev \
    curl

# install 'install-php-extensions' script
RUN curl -sSLf https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
     -o /usr/local/bin/install-php-extensions \
  && chmod +x /usr/local/bin/install-php-extensions

# install extensions
RUN install-php-extensions \
    amqp \
    bcmath \
    bz2 \
    calendar \
    curl \
    exif \
    gd \
    intl \
    mbstring \
    mysqli \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    soap \
    sodium \
    sockets \
    xsl \
    zip \
    $( [ "${BUILD_ENV:-}" = "dev" ] && echo xdebug )

# remove unused deps
RUN apk del $PHPIZE_DEPS

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer

# install supervisor
RUN mkdir /var/log/supervisor \
    && chmod 777 /var/log/supervisor \
    && mkdir -p /etc/supervisor/conf.d

COPY config/supervisord.conf /etc/supervisord.conf

# create user
RUN addgroup -g ${GROUP_ID} -S ${USER} \
  && adduser -u ${USER_ID} -D -S -G ${USER} ${USER} \
  && mkdir ${APP_PATH}  \
  && chown -R ${USER}:${USER} ${APP_PATH}

WORKDIR ${APP_PATH}
