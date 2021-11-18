#!/usr/bin/env bash

# BEGIN ########################################################################
echo -e "-- ----------------- --\n"
echo -e "-- BEGIN ${HOSTNAME} --\n"
echo -e "-- ----------------- --\n"

# VARIABLES ####################################################################
echo -e "-- Setting global variables\n"
APACHE_CONFIG=/etc/apache2/apache2.conf
LOCALHOST=localhost

# BOX ##########################################################################
echo -e "-- Updating packages list\n"
apt-get update -y -qq

# APACHE #######################################################################
echo -e "-- Installing Apache web server\n"
apt-get install -y apache2 libapache2-mod-php > /dev/null 2>&1

if [ ! -f /var/www/html/wp-login.php ]; then
    echo -e "-- Installing Wordpress\n"
    rm /var/www/html/index.html
    cd /var/www/html
    wget "http://wordpress.org/latest.tar.gz"
    tar xzf latest.tar.gz
    mv wordpress/* .
fi

echo -e "-- Adding ServerName to Apache config\n"
grep -q "ServerName ${LOCALHOST}" "${APACHE_CONFIG}" || echo "ServerName ${LOCALHOST}" >> "${APACHE_CONFIG}"

echo -e "-- Restarting Apache web server\n"
service apache2 restart

# END ##########################################################################
echo -e "-- -------------- --"
echo -e "-- END ${HOSTNAME} --"
echo -e "-- -------------- --"
