# This file is a template, and might need editing before it works on your project.
FROM php:7.3-apache

RUN apt-get update && apt-get install -y\
    php-cli unzip

WORKDIR /tmp

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php\
    && HASH=`curl -sS https://composer.github.io/installer.sig`\
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
