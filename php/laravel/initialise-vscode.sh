#!/bin/bash

# Set PHP and Node.js versions
PHP_VERSION=${PHP_VERSION-}
NODE_VERSION=${NODE_VERSION-}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}
PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Download scripts from the scripts repository
git clone https://github.com/PixNyb/dockerised-vscode-scripts /tmp/scripts
sudo mv /tmp/scripts/php/laravel/scripts/* /usr/local/bin
chmod +x /usr/local/bin/*
rm -rf /tmp/scripts

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

		if [ -z $PHP_VERSION ]; then
			FRAMEWORK_VERSION=$(cat composer.json | jq -r '.require."laravel/framework" // ""')
			if [ -n "$FRAMEWORK_VERSION" ]; then
				PHP_VERSION=$(curl -s https://repo.packagist.org/p2/laravel/framework.json | jq -r ".packages.\"laravel/framework\".\"$FRAMEWORK_VERSION\".require.php // \"\"")
			fi
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

# If there's a .nvmrc or .tool-versions file installed, read it to get the NODE_VERSION
if [ -z $NODE_VERSION ]; then
	if [ -f .nvmrc ]; then
		NODE_VERSION=$(cat .nvmrc)
	elif [ -f .tool-versions ]; then
		NODE_VERSION=$(grep -E "^nodejs" .tool-versions | awk '{print $2}')
	elif [ -f package-lock.json ]; then
		$LOCKFILE_VERSION=$(cat package-lock.json | jq -r '.lockfileVersion // ""')
		case $LOCKFILE_VERSION in
		1)
			NODE_VERSION="14"
			;;
		2)
			NODE_VERSION="18"
			;;
		*)
			NODE_VERSION="22"
			;;
		esac
	fi
fi
cd $curdir

# Install PHP and necessary PHP extensions
sudo apt-get install -y php${PHP_VERSION}-cli php${PHP_VERSION}-bcmath php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-tokenizer php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-gd php${PHP_VERSION}-intl

# Download and install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Set the environment variables for composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Convert the node version to the format required by the nvm script
NODE_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 1)
NODE_VERSION=$(echo $NODE_VERSION | sed 's/^v//')

# Install Laravel using Composer
composer global require laravel/installer -n

# Install Node.js and npm using nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION

# Install yarn
npm install -g yarn

# Install MySQL
sudo apt-get install -y mysql-server
sudo service mysql start

# Set the MySQL root password
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '${MYSQL_PASSWORD}';"

# Create a new user and database with the $PROJECT_NAME name
sudo mysql -u root -p"${MYSQL_PASSWORD}" -e "CREATE DATABASE ${PROJECT_NAME};"
sudo mysql -u root -p"${MYSQL_PASSWORD}" -e "CREATE USER '${PROJECT_NAME}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
sudo mysql -u root -p"${MYSQL_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${PROJECT_NAME}.* TO '${PROJECT_NAME}'@'%';"
sudo mysql -u root -p"${MYSQL_PASSWORD}" -e "FLUSH PRIVILEGES;"

# TODO: Install xdebug

# Set up the Laravel project
cd $PROJECT_FOLDER

# If the project contains a composer-lock.json file, install the dependencies
if [ -f composer.lock ]; then
	composer install -n &
fi

# If the project contains a package-lock.json file, install the dependencies
if [ -f package-lock.json ]; then
	npm install &
fi

# If the project contains a yarn.lock file, install the dependencies
if [ -f yarn.lock ]; then
	yarn install &
fi

# If the project contains a .env.example file, copy it to .env
if [ -f .env.example ]; then
	cp .env.example .env
fi

# Attempt to fill in the .env file with the database credentials
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${PROJECT_NAME}/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=${PROJECT_NAME}/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${MYSQL_PASSWORD}/" .env

# Generate the application key and set up the Laravel project
php artisan key:generate
php artisan link:storage

# Make some aliases for the user
echo "alias serve='php artisan serve --host=0.0.0.0'" >>~/.bashrc
echo "alias migrate='php artisan migrate'" >>~/.bashrc
echo "alias seed='php artisan db:seed'" >>~/.bashrc
echo "alias watch='npm run dev'" >>~/.bashrc
echo "alias build='npm run build'" >>~/.bashrc
echo "alias artisan='php artisan'" >>~/.bashrc
echo "alias tinker='php artisan tinker'" >>~/.bashrc

echo "echo -e 'You are currently running a \033[1;31mLaravel\033[0m specialisation container.'" >>~/.bashrc
echo "echo -e 'Useful commands:'" >>~/.bashrc
echo "echo -e '  - \033[1;34mserve\033[0m: Run the Laravel development server'" >>~/.bashrc
echo "echo -e '  - \033[1;34mmigrate\033[0m: Run the Laravel database migrations'" >>~/.bashrc
echo "echo -e '  - \033[1;34mseed\033[0m: Run the Laravel database seeders'" >>~/.bashrc
echi "echo -e '  - \033[1;34martisan\033[0m: Shortcut for the artisan command (php artisan)'" >>~/.bashrc
echo "echo -e '  - \033[1;34mtinker\033[0m: Open Laravel tinker'" >>~/.bashrc
echo "echo -e '  - \033[1;34mwatch\033[0m: Watch assets for changes'" >>~/.bashrc
echo "echo -e '  - \033[1;34mbuild\033[0m: Build assets for production'" >>~/.bashrc
echo "echo -e 'Included scripts:'" >>~/.bashrc
echo "echo -e '  - \033[1;34mimport-db\033[0m: Import a database dump into the database'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: import-db <sql_file>'" >>~/.bashrc
echo "echo -e '  - \033[1;34mexport-db\033[0m: Export the database into a dump file'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: export-db <dump_file>'" >>~/.bashrc
echo "echo -e '  - \033[1;34mclear-db\033[0m: Remove all tables from the database'" >>~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: clear-db <dump_file>'" >>~/.bashrc


