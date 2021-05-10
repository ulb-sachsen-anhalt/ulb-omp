FROM alpine:3.11

LABEL maintainer="Public Knowledge Project <marc.bria@gmail.com>"

WORKDIR /var/www/html

ARG USE_VERSION=stable-3_3_1

ENV COMPOSER_ALLOW_SUPERUSER=1  \
	SERVERNAME="localhost"      \
	HTTPS="on"                  \
	OMP_VERSION=${USE_VERSION} \
	OMP_CLI_INSTALL="0"         \
	OMP_DB_HOST="localhost"     \
	OMP_DB_USER="omp"           \
	OMP_DB_PASSWORD="omp"       \
	OMP_DB_NAME="omp"           \
	OMP_WEB_CONF="/etc/apache2/conf.d/omp.conf"	\
	OMP_CONF="/var/www/html/config.inc.php"


# PHP_INI_DIR to be symmetrical with official php docker image
ENV PHP_INI_DIR /etc/php/7.3

# When using Composer, disable the warning about running commands as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Basic packages
ENV PACKAGES 		\
	apache2 		\
	apache2-ssl 	\
	apache2-utils 	\
	ca-certificates \
	curl 			\
	ttf-freefont	\
	dcron 			\
	patch			\
	php7			\
	php7-apache2	\
	runit 			\
	supervisor

# PHP extensions
ENV PHP_EXTENSIONS	\
	php7-bcmath		\
	php7-bz2		\
	php7-calendar	\
	php7-ctype		\
	php7-curl		\
	php7-dom		\
	php7-exif		\
	php7-fileinfo	\
	php7-ftp		\
	php7-gettext	\
	php7-intl		\
	php7-iconv		\
	php7-json		\
	php7-mbstring	\
	php7-mysqli		\
	php7-opcache	\
	php7-openssl	\
	php7-pdo_mysql	\
	php7-phar		\
	php7-posix		\
	php7-session	\
	php7-shmop		\
	php7-simplexml	\
	php7-sockets	\
	php7-sysvmsg	\
	php7-sysvsem	\
	php7-sysvshm	\
	php7-tokenizer	\
	php7-xml		\
	php7-xmlreader	\
	php7-xmlwriter	\
	php7-zip		\
	# ulb optional installed
	php7-xsl		\
	php7-zlib

# Required to build OMP:
ENV BUILDERS 		\
	git 			\
	nodejs 			\
	npm

# To make a smaller image, we start with the copy.
# This let us joining runs in a single layer.
COPY ./resources/exclude.list /tmp/exclude.list

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps $BUILDERS \
	&& apk add --no-cache $PACKAGES \
	&& apk add --no-cache $PHP_EXTENSIONS \
# Building OMP:
	# Configure and download code from git
	&& git config --global url.https://.insteadOf git:// \
	&& git config --global advice.detachedHead false \
	&& git clone --depth 1 --single-branch --branch $OMP_VERSION --progress https://github.com/pkp/omp.git . \
	&& git submodule update --init --recursive >/dev/null \
	# Composer vudu:
 	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar \
	# To avoid timeouts with gitHub we use tokens:
	# TODO: Replace personal token by an official one.
 	# && composer.phar config -g github-oauth.github.com 58778f1c172c09f3add6cb559cbadd55de967d47 \
	# Install Composer Deps:
 	&& composer.phar --working-dir=lib/pkp install --no-dev \
	&& composer.phar --working-dir=plugins/paymethod/paypal install --no-dev  \
	## ulb citationStyleLanguage causes errors
	#	&& composer.phar --working-dir=plugins/generic/citationStyleLanguage install --no-dev \
	# Node joins to the party:
	&& npm install -y && npm run build \
# Create directories
	&& mkdir -p /var/www/files /run/apache2  /run/supervisord/ \
	&& cp config.TEMPLATE.inc.php config.inc.php \
	&& chown -R apache:apache /var/www/* \
# Prepare freefont for captcha 
	&& ln -s /usr/share/fonts/TTF/FreeSerif.ttf /usr/share/fonts/FreeSerif.ttf \
# Prepare crontab
	&& echo "0 * * * *   omp-run-scheduled" | crontab - \
# Prepare httpd.conf
	&& sed -i -e '\#<Directory />#,\#</Directory>#d' /etc/apache2/httpd.conf \
	&& sed -i -e "s/^ServerSignature.*/ServerSignature Off/" /etc/apache2/httpd.conf \
# Clear the image (list of files to be deleted in exclude.list).
	&& cd /var/www/html \
 	&& rm -rf $(cat /tmp/exclude.list)  \
	&& apk del --no-cache .build-deps \
	&& rm -rf /tmp/* \
	&& rm -rf /root/.cache/* \
# Some folders are not required (as .git .travis.yml test .gitignore .gitmodules ...)
	&& find . -name ".git" -exec rm -Rf '{}' \; \
	&& find . -name ".travis.yml" -exec rm -Rf '{}' \; \
	&& find . -name "test" -exec rm -Rf '{}' \; \
	&& find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm -Rf '{}' \;

COPY root/ /
COPY ./resources/favicon.ico /var/www/html/favicon.ico

EXPOSE 80 443

VOLUME [ "/var/www/files", "/var/www/html/public" ]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
