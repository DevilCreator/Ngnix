#!/bin/bash
echo "You can choose what webpage hosting software can be installed."
echo "The two available packages are: apache and Nginx"
echo "You may now type it in:" 

read server
if ["$server" = "apache"]
	then
		echo "Apache will now be installed"
		sudo apt update
		sudo apt install apache2 -y
		sudo apt install php libapache2-mod-php -y
	fi

if ["$server" = "Nginx"]
	then
		echo "Nginx will now be installed"
		sudo apt update
		sudo apt install nginx php-fpm
		sudo apt install php libapache2-mod-php -y
		sudo systemctl stop nginx.service
		sudo systemctl start nginx.service
		sudo systemctl enable nginx.service
		echo "Change the following line"
		echo "index index.html index.htm index.nginx-debian.html;"
		echo "to this to setup Nginx correctly"
		echo "index index.html index.htm index.php;"
		echo ""
		echo "after you have completed this continue on with:"
		echo "#location = \.php$ {"
		echo "# include snippets/fastcgi-php.conf; "
		echo "#"
		echo "# # With php5-cgi alone: "
		echo "# fastcgi_pass 127.0.0.1:9000; "
		echo "# # With php5-fpm: "
		echo "# fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;"
		echo "#}"
		echo ""
		echo "And modify these lines into:"
		echo ""
		echo "location ~ \.php$ {"
		echo "include snippets/fastcgi-php.conf;"
		echo "fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;"
		echo "}"
		echo ""
		echo "continue?"
		read continuenginx
		chown www-data:www-data /var/www
		chmod 744 /var/www
		sudo nano /etc/nginx/sites-available/default
		sudo chown -R www-data:pi /var/www/html/ 
		sudo chmod -R 770 /var/www/html/
		echo "<?php phpinfo(); ?>" > /var/www/html/index.php
		sudo /etc/init.d/nginx restart

	fi	

echo ""
echo "Now we can start on the database software"
echo "You can choose from mySQL or Mariadb"
echo "You may now type:"
read dbsoftware

if ["$dbsoftware" = "mySQL"]
	then
	echo "MySQL is now being installed"
	sudo apt-get update
	sudo apt-get install mysql-server
	echo "Please enter y to set root password and press enter"
	echo "Please enter a password if requested and press enter"
	echo "Please enter y to remove the anonymous user and press enter"
	echo "please enter y to disable remote login and press enter"
	echo "please enter y to remove test databases and press enter"
	echo "please enter y to reload previleges tables and press enter"
	echo ""
	echo "continue?"
	read continueSQL
	sudo mysql_secure_installation
	sudo mysql -u root -p
	show databases;
	fi

if ["$dbsoftware" = "Mariadb"]
	then
	echo "MariaDB is now being installed"
	sudo apt update
	sudo apt upgrade
	sudo apt install mariadb-server
	echo "Please enter y to remove the anonymous user and press enter"
	echo "please enter y to disable remote login and press enter"
	echo "please enter y to remove test databases and press enter"
	echo "please enter y to reload previleges tables and press enter"
	echo ""
	echo "continue?"
	read continueMDB
	sudo systemctl stop mariadb.service
	sudo systemctl start mariadb.service
	sudo systemctl enable mariadb.service
	sudo mysql_secure_installation
	mysql
	mysql -uroot -p
	show databases;
	fi

echo "Time to install NextCloud"
sudo apt install php-fpm php-mbstring php-xmlrpc php-soap php-apcu php-smbclient php-ldap php-redis php-gd php-xml php-intl php-json php-imagick php-mysql php-cli php-mcrypt php-ldap php-zip php-curl
sudo mysql -u root -p
CREATE DATABASE nextcloud;
CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY 'new_password_here';
GRANT ALL ON nextcloud.* TO 'nextclouduser'@'localhost' IDENTIFIED BY 'user_password_here' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;

cd /tmp && wget https://download.nextcloud.com/server/releases/nextcloud-11.0.1.zip
unzip nextcloud-11.0.1.zip
sudo mv nextcloud /var/www/html/nextcloud/
sudo chown -R www-data:www-data /var/www/html/nextcloud/
sudo chmod -R 755 /var/www/html/nextcloud/

echo "Now go to https://websiteforstudents.com/install-nextcloud-on-ubuntu-17-04-17-10-with-nginx-mariadb-and-php/"
echo "On step 6, copy the configuration given there into /etc/nginx/sites-available/nextcloud"
echo "save and continue when done"
echo ""
echo "continue?"
read continuenc

sudo nano /etc/nginx/sites-available/nextcloud
sudo ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/
sudo systemctl restart nginx.service

echo "Nextcloud is now setup, let's continue with the fail2ban"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

echo "use CTRL+W to search for [sshd]"
echo "add in 2 lines here with: enabled = true"
echo "and: filter = sshd"
echo ""
echo "continue and make another line"
echo "and add: banaction = iptables-multiport"
echo "add another line: bantime = -1 or 3600 (time in seconds)"
echo "lastly add in: maxretry = 3 (can be more or less depending on preferences"
echo "then save"
echo "continue?"
read continuef2b

sudo nano /etc/fail2ban/jail.local
sudo service fail2ban restart

echo "And thats fail2ban completed too!"
echo "Lets continue onwards to greatness"
echo ""
echo "Or thats what I hope for you"
echo "Sure not going to be as smart as Ben Renting"

echo "Enough jokes, time to set up self signed certificates"
echo "continue"
read continueCert

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

echo "Lets create the self-signed.conf file"
echo "add the following two lines to the config file"
echo "ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;"
echo "ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;"
echo "once this is all in, save and close"
echo "continue?"
read continueSSL
sudo nano /etc/nginx/snippets/self-signed.conf

echo "Lets create the ssl-params.conf file"
echo "go to https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04"
echo "and use search to navigate to: /etc/nginx/snippets/ssl-params.conf"
echo "It should send you on the second result to the configuration file. Copy this into the file you are creating"
echo "Make the nessecary changes which are also explained in the text above the config file. And save&close when done."
echo "continue?"
read continueSSL2
sudo nano /etc/nginx/snippets/ssl-params.conf

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

echo "Now open up the server block file"
echo "Remember that url I gave you for the params.conf? well, use CTRL+F to find:"
echo "/etc/nginx/sites-available/default"
echo "On the 7th result you will find the code that you need to copy over into the file."
echo "Make sure your file looks like the code provided here"
echo "Once done, save and close the file"
echo "continue?"
read continueSSL3
sudo nano /etc/nginx/sites-available/default

sudo ufw app list
sudo ufw status
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
sudo ufw status

sudo nginx -t
sudo systemctl restart nginx

echo "And that should be the SSL certificate done"
echo "Last thing we should have to do is the firewall"
echo "continue?"
read continueFW1
apt-get iptables-persistent
ii iptables 1.4.12-1ubuntu4 administration tools for packet filtering and NAT
ip_tables 18106 1 iptable_filter
iptables -L

iptables -I INPUT -p tcp --dport 22 -s 192.168.1.1 -j ACCEPT
iptables -L
iptables -P INPUT DROP

iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -L -n

iptables -I INPUT -i lo -j ACCEPT
iptables -L -n

iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -L -n

iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -L -n


/etc/init.d/iptables-persistent save

runlevel
ls -la /etc/rc2.d/ | grep iptables

echo "If everything went right. you now should have a working system"
echo "This has been brought to you by Ben Renting, an IT student at ROC Nijmegen. June 2021"
read last
