#!/bin/bash

MYSQL_DIR="/var/lib/mysql"

SSH_PASS=${SSH_PASS:-$(pwgen -s 12 1)}
echo "mysql:$SSH_PASS" |chpasswd


echo ""
if [[ ! -d $MYSQL_DIR/mysql ]]; then
  echo "=> An empty MySQL volume found in $MYSQL_DIR"
  echo "=> Initializing Empty MySQL Install - Standby"

	if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
    cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
  fi 

  mysql_install_db > /dev/null 2>&1
  sleep 5
  echo "=> Completed Initializing Empty MySQL"
  /usr/bin/mysqld_safe > /dev/null 2>&1 &

	RET=1
	while [[ RET -ne 0 ]]; do
	    echo "=> Waiting for confirmation of MySQL service startup"
	    sleep 5
	    mysql -uroot -e "status" > /dev/null 2>&1
	    RET=$?
	done

	ROOT_PASS=${MYSQL_ROOT_PASS:-$(pwgen -s 12 1)}
	ADMIN_PASS=${MYSQL_ADMIN_PASS:-$(pwgen -s 12 1)}
	_word=$( [ ${MYSQL_ADMIN_PASS} ] && echo "preset" || echo "random" )
	echo "=> Creating MySQL admin user with ${_word} password"

	mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$ADMIN_PASS'"
	mysql -uroot -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY '$ADMIN_PASS'"
	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION"

	# UPDATE ROOT PASSWORD
	mysql -uroot -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROOT_PASS}');"


	echo "=> Done!"

	echo "========================================================================"
	echo ""
	echo "Root Password: $ROOT_PASS"
	echo "Admin Password: $ADMIN_PASS"
	echo "SSH User: 'mysql' / Password: $SSH_PASS"
	echo "Please remember to change the above passwords as soon as possible!"
	echo "MySQL user 'root' only allows local connections"
	echo ""
	echo "========================================================================"


else
	echo "==========================="
	echo ""
  echo "Found existing MySQL Volume"
  echo "SSH User: 'mysql' / Password: $SSH_PASS"
  echo ""
  echo "==========================="
fi






exec supervisord -n