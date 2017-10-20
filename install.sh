#!/bin/bash -x
apt-get -y install apache2 php phpmyadmin mariadb-server php-imap mcrypt
/usr/bin/mysql_secure_installation
mysql -uroot -p -e "CREATE USER 'myadmin'@'localhost' IDENTIFIED BY '230568'; GRANT ALL PRIVILEGES ON *.* TO 'myadmin'@'localhost' WITH GRANT OPTION;"
