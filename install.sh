#!/bin/bash -x
passwd1 () {

data=$(tempfile 2>/dev/null)
# trap it
trap "rm -f $data" 0 1 2 5 15
# get password
dialog --title "Password" \
	--clear \
	--insecure \
	--passwordbox "$names" 10 30 2> $data

ret=$?

# make decision
case $ret in
	0)
	  pass1=$(cat $data);;
	1)
	  echo "Cancel pressed."
	  passwd1;;
	255)
	  [ -s $data ] &&  cat $data || echo "ESC pressed."
	  passwd1;;
esac

if [ -z "$pass1" ];then  passwd1;fi

}

apt-get -y install apache2 php phpmyadmin mariadb-server php-imap mcrypt

names="Enter root password mysql"
while [ -z "$pass1" ]
do
	passwd1
	tmp1=$pass1
	names="Enter the password again"
	passwd1
	if [[ "$tmp1" != "$pass1" ]]
	then
	  names=" Passwords do not match \n Enter root password mysql "
	  pass1=""
	fi
done
mysql -e "SET PASSWORD FOR root@localhost=PASSWORD($pass1);"
passroot=$pass1
pass1=""

names="Enter password phpmyadmin user myadmin"
while [ -z "$pass1" ]
do
        passwd1
        tmp1=$pass1
        names="Enter the password again"
        passwd1
        if [[ "$tmp1" != "$pass1" ]]
        then
          names=" Passwords do not match \n Enter password phpmyadmin user myadmin "
          pass1=""
        fi
done

mysql -uroot -p$passroot -e "CREATE USER 'myadmin'@'localhost' IDENTIFIED BY $pass1; GRANT ALL PRIVILEGES ON *.* TO 'myadmin'@'localhost' WITH GRANT OPTION;"
