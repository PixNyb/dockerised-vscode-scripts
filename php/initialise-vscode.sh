#!/bin/bash

# Add extension to the list of extensions
extensions=(
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

# Set the PHP version
PHP_VERSION=${PHP_VERSION-}
PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Update package lists
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

curdir=$(pwd)
cd $PROJECT_FOLDER
# Attempt to find the PHP version by checking the composer.json file
if [ -z $PHP_VERSION ]; then
	if [ -f composer.json ]; then
		# In order of priority, check for the PHP version in the composer.json file:
		# 1. config.platform.php
		# 2. require.php
		PHP_VERSION=$(cat composer.json | jq -r '.config.platform.php // ""')

		if [ -z $PHP_VERSION ]; then
			PHP_VERSION=$(cat composer.json | jq -r '.require.php // ""')
		fi

		# Make sure to format the PHP version correctly.
		# In the case of an || operator, the PHP version should be the highest version.
		PHP_VERSION=$(echo $PHP_VERSION | sed 's/[^0-9|.]//g')
		PHP_VERSION=$(echo $PHP_VERSION | tr '|' '\n' | sort -rV | head -n 1)

		# Make sure the PHP version is in the format required by the package manager, make sure to properly parse major and minor versions in the format x.x.
		# If a version is in the format x.x.x, cut off the last version number.
		# If a version is in the format x.x, leave it as is.
		# If a version is in the format x, add a .0 to the end.
		PHP_VERSION=$(echo $PHP_VERSION | cut -d '.' -f 1,2)
		if [[ $PHP_VERSION == *"."*"."* ]]; then
			PHP_VERSION=$(echo $PHP_VERSION | sed 's/\.[0-9]*$//')
		elif [[ $PHP_VERSION != *"."* ]]; then
			PHP_VERSION="${PHP_VERSION}.0"
		fi
	fi
fi
cd $curdir

# Install PHP and necessary PHP extensions
sudo apt-get install -y libapache2-mod-php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-bcmath php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-tokenizer php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-gd php${PHP_VERSION}-intl

# Download and install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Set the environment variables for composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Install apache2 and enable it
sudo apt-get install -y apache2

# Point apache to $PROJECT_FOLDER/public
chmod 755 ~
sudo sed -i "s|/var/www/html|$PROJECT_FOLDER/public|g" /etc/apache2/sites-available/000-default.conf

# Add the directory configuration to apache
sudo sed -i "s|</VirtualHost>|    <Directory $PROJECT_FOLDER/public>\n        Options Indexes FollowSymLinks\n        AllowOverride All\n        Require all granted\n    </Directory>\n</VirtualHost>|g" /etc/apache2/sites-available/000-default.conf

# Make apache run under the current user
USER=$(whoami)
sudo sed -i "s|export APACHE_RUN_USER=www-data|export APACHE_RUN_USER=$USER|g" /etc/apache2/envvars
sudo sed -i "s|export APACHE_RUN_GROUP=www-data|export APACHE_RUN_GROUP=$USER|g" /etc/apache2/envvars

# Enable Apache mod_rewrite
sudo a2enmod rewrite
sudo a2enmod php${PHP_VERSION}

# Install Xdebug with pecl
sudo apt-get install -y php-pear php${PHP_VERSION}-dev
case $PHP_VERSION in
5.5 | 5.6 | 7.0 | 7.1)
	sudo pecl install xdebug-2.5.5
	sudo bash -c "echo -e 'zend_extension=$(find /usr/lib/php -name xdebug.so)\nxdebug.remote_enable=1\nxdebug.remote_autostart=1' > /etc/php/${PHP_VERSION}/apache2/conf.d/20-xdebug.ini"
	;;
7.2 | 7.3 | 7.4 | 8.0)
	sudo pecl install xdebug-2.9.8
	sudo bash -c "echo -e 'zend_extension=$(find /usr/lib/php -name xdebug.so)\nxdebug.remote_enable=1\nxdebug.remote_autostart=1' > /etc/php/${PHP_VERSION}/apache2/conf.d/20-xdebug.ini"
	;;
8.1 | 8.2 | 8.3 | 8.4)
	sudo pecl install xdebug
	sudo bash -c "echo -e 'zend_extension=$(find /usr/lib/php -name xdebug.so)\nxdebug.mode=debug\nxdebug.start_with_request=yes' > /etc/php/${PHP_VERSION}/apache2/conf.d/20-xdebug.ini"
	;;
esac

# Start Apache
sudo service apache2 start

# Set up the PHP project
cd $PROJECT_FOLDER

# If the project contains a composer-lock.json file, install the dependencies
if [ -f composer.lock ]; then
	composer install -n &
fi

echo "echo -e 'You are currently running a \033[1;36mPHP\033[0m generic container.'" >>~/.bashrc
