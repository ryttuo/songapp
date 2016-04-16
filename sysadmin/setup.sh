apt-get update
apt-get install -y -V git


#!/bin/bash
# -----------------------------------------------------------------------------
# -- Apache
# -----------------------------------------------------------------------------


install_apache()
{
  echo "----------------------------------------------------------------------"
  echo "--"
  echo "-- Adding Apache2.4 repository"
  echo "--"
  echo "----------------------------------------------------------------------"
  apt-add-repository ppa:ptn107/apache
  #add-apt-repository ppa:ondrej/apache2
  apt-get update

  echo "----------------------------------------------------------------------"
  echo "--"
  echo "-- Installing Apache 2.4"
  echo "--"
  echo "----------------------------------------------------------------------"
  apt-get -y -V install apache2

  echo "Enabling Apache Extensions"
  # apt-get install libapache2-mpm-itk apache2-mpm-itk

  a2enmod proxy
  a2enmod rewrite
  a2enmod headers
  service apache2 restart
}

CMDA=$(apache2 -v 2>&1)
if [[ $CMDA != *"Apache server"* ]]
then
  install_apache

  echo "----------------------------------------------------------------------"
  echo "--"
  echo "-- Apache Setup Completed"
  echo "--"
  echo "----------------------------------------------------------------------"
fi

install_php56()
{
  echo "Adding Latest Repositories - PHP"
  add-apt-repository ppa:ondrej/php5-5.6
  apt-get update

  apt-get -y -V install php5
  apt-get -y -V install php5-dev
  apt-get -y -V install php5-cli php-pear php5-apcu php5-curl php5-memcache php5-memcached php-gettext php5-gd php5-ldap php5-imagick php5-mcrypt php5-mysqlnd phpunit php5-xdebug 

  pear channel-update
}



CMDA=$(php -v 2>&1)
if [[ $CMDA != *"PHP 5.6"* ]]
then
  install_php56
fi

install_mysql56()
{
  echo "----------------------------------------------------------------------"
  echo "--"
  echo "-- Installing MySQL 5.6"
  echo "--"
  echo "--"
  echo "-- Default password: 123456"
  echo "----------------------------------------------------------------------"
  echo ""

  wget http://dev.mysql.com/get/mysql-apt-config_0.6.0-1_all.deb
  dpkg -i mysql-apt-config_0.6.0-1_all.deb
  apt-get update

  # Set default password
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
  apt-get -y -V install mysql-server mysql-client
}

install_configfiles()
{
  echo "----------------------------------------------------------------------"
  echo "--"
  echo "-- Setting up MySQL Configurations Files"
  echo "--"
  echo "-- Files:"
  echo "--       /etc/mysql/conf.d/utf8.cnf"
  echo "--       /etc/mysql/conf.d/slowquery.cnf"
  echo "--"
  echo "----------------------------------------------------------------------"

  echo ""
  echo ""
  echo "Setting All Connections to UTF-8"
  #
  # MySQL 5.6 UTF-8 Configurations
  #
  echo "# Setting All Connections to UTF-8" > /etc/mysql/conf.d/utf8.cnf && \
  echo "" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "[client]" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "default-character-set=utf8" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "[mysql]" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "default-character-set=utf8" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "[mysqld]" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "character-set-server = utf8" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "collation-server = utf8_general_ci" >> /etc/mysql/conf.d/utf8.cnf && \
  echo "init-connect='SET NAMES utf8'" >> /etc/mysql/conf.d/utf8.cnf && \
  service mysql restart

  #
  # MySQL Configurations SlowQueryLog
  #
  echo "Setting Slow Query Log - Disable by default"
  echo "# Setting the slow query log" > /etc/mysql/conf.d/slowquery.cnf && \
  echo "[mysqld]" >> /etc/mysql/conf.d/slowquery.cnf && \
  echo "log-output=TABLE" >> /etc/mysql/conf.d/slowquery.cnf && \
  echo "long_query_time=0" >> /etc/mysql/conf.d/slowquery.cnf && \
  echo "min_examined_row_limit=1" >> /etc/mysql/conf.d/slowquery.cnf && \
  echo "slow_query_log=0" >> /etc/mysql/conf.d/slowquery.cnf && \
  service mysql restart
}

CMDA=$(mysql --help 2>&1)
if [[ $CMDA != *"Distrib 5.6"* ]]
then
  install_mysql56
  install_configfiles
  #mysql config
  mysql -uroot -proot -e "CREATE DATABASE songapp"
  mysql -uroot -proot -e "grant all privileges on songapp.* to 'root'@'localhost' identified by 'root'"
  mysql -uroot -proot songapp < /var/www/database/songapp.sql
fi


#install vim
sudo apt-get install -y vim


#apache setup
apt-get install -y -V php5-mysql



/etc/apache2/sites-available/default
sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/" /etc/apache2/sites-available/default

service apache2 restart