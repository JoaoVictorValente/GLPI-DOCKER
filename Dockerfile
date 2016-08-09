#Dockerfile pour créer une image docker de GLPi fonctionnelle (avec apache2 et php5)

#On choisit une debian
FROM debian:latest

MAINTAINER DiouxX "github@diouxx.be"

#Ne pas poser de question à l'installation
ENV DEBIAN_FRONTEND noninteractive

ENV VERSION_GLPI 0.90.5
ENV SRC_GLPI https://github.com/glpi-project/glpi/releases/download/${VERSION_GLPI}/glpi-${VERSION_GLPI}.tar.gz
ENV TAR_GLPI glpi-${VERSION_GLPI}.tar.gz
ENV FOLDER_GLPI glpi/
ENV FOLDER_WEB /var/www/html/

#Installation d'apache et de php5 avec extension
RUN apt update \
&& apt -y install \
apache2 \
php5 \
php5-mysql \
php5-ldap \
php5-xmlrpc \
php5-imap \
curl \
php5-curl \
php5-gd \
wget

#Téléchargement des sources de GLPI
RUN wget -P ${FOLDER_WEB} ${SRC_GLPI} \
	&& tar -xf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}\
	&& rm -Rf ${FOLDER_WEB}${TAR_GLPI} \
	&& chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}

#Modification du fichier 
RUN echo "<VirtualHost *:80>\n\tDocumentRoot /var/www/html/glpi\n\n\t<Directory /var/www/html/glpi>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-glpi.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-glpi.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

#Activation du module rewrite d'apache
RUN a2enmod rewrite && service apache2 restart

#Exposition des ports
EXPOSE 80 443

#Partage du volume
VOLUME /var/www/html/glpi

#Lancement du service apache a l'initialisation du conteneur
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
