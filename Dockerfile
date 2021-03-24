# This file is a template, and might need editing before it works on your project.
FROM php:7.3-apache

RUN apt-get update && apt-get install -y

WORKDIR /tmp

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php\
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer
