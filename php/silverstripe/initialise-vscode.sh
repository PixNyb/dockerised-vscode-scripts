#!/bin/bash

# Add extension to the list of extensions
extensions=(
	"bmewburn.vscode-intelephense-client"
	"porifa.laravel-intelephense"
	"xdebug.php-debug"
	"devsense.profiler-php-vscode"
    "adrianhumphreys.silverstripe"
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

# Set PHP and Node.js versions
PHP_VERSION=${PHP_VERSION:-}
NODE_VERSION=${NODE_VERSION:-}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}
PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Download scripts from the scripts repository
git clone https://github.com/PixNyb/dockerised-vscode-scripts /tmp/scripts
sudo mv /tmp/scripts/php/silverstripe/scripts/* /usr/local/bin
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
        # 3. check packagist for the required PHP version for `silverstripe/recipe-cms` if it's installed
        # 4. check packagist for the required PHP version for `silverstripe/framework` if it's installed
        PHP_VERSION=$(cat composer.json | jq -r '.config.platform.php // ""')

        if [ -z $PHP_VERSION ]; then
            PHP_VERSION=$(cat composer.json | jq -r '.require.php // ""')
        fi

        if [ -z $PHP_VERSION ]; then
            RECIPE_CMS_VERSION=$(cat composer.json | jq -r '.require."silverstripe/recipe-cms" // ""')
            if [ -n "$RECIPE_CMS_VERSION" ]; then
                PHP_VERSION=$(curl -s https://repo.packagist.org/p2/silverstripe/recipe-cms.json | jq -r ".packages.\"silverstripe/recipe-cms\".\"$RECIPE_CMS_VERSION\".require.php // \"\"")
            fi
        fi

        if [ -z $PHP_VERSION ]; then
            FRAMEWORK_VERSION=$(cat composer.json | jq -r '.require."silverstripe/framework" // ""')
            if [ -n "$FRAMEWORK_VERSION" ]; then
                PHP_VERSION=$(curl -s https://repo.packagist.org/p2/silverstripe/framework.json | jq -r ".packages.\"silverstripe/framework\".\"$FRAMEWORK_VERSION\".require.php // \"\"")
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
sudo apt-get install -y libapache2-mod-php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-bcmath php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-tokenizer php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-gd php${PHP_VERSION}-intl

# Download and install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Set the environment variables for composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Convert the node version to the format required by the nvm script
NODE_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 1)
NODE_VERSION=$(echo $NODE_VERSION | sed 's/^v//')

# Install Node.js and npm using nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION

# Install yarn
npm install -g yarn

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

sudo mkdir -p /var/log/silverstripe /tmp/silverstripe-cache
sudo chown -R $USER:$USER /var/lock/apache2 /var/log/apache2 /var/log/silverstripe /tmp/silverstripe-cache

# Enable Apache mod_rewrite
sudo a2enmod rewrite
sudo a2enmod php${PHP_VERSION}

# Install Xdebug with pecl
sudo apt-get install -y php-pear php${PHP_VERSION}-dev
case $PHP_VERSION in
    5.5|5.6|7.0|7.1)
        sudo pecl install xdebug-2.5.5
        sudo bash -c "echo -e 'zend_extension=$(find /usr/lib/php -name xdebug.so)\nxdebug.remote_enable=1\nxdebug.remote_autostart=1' > /etc/php/${PHP_VERSION}/apache2/conf.d/20-xdebug.ini"
        ;;
    7.2|7.3|7.4|8.0)
        sudo pecl install xdebug-2.9.8
        sudo bash -c "echo -e 'zend_extension=$(find /usr/lib/php -name xdebug.so)\nxdebug.remote_enable=1\nxdebug.remote_autostart=1' > /etc/php/${PHP_VERSION}/apache2/conf.d/20-xdebug.ini"
        ;;
    8.1|8.2|8.3|8.4)
        sudo pecl install xdebug
        sudo bash -c "echo -e 'zend_extension=$(find /usr/lib/php -name xdebug.so)\nxdebug.mode=debug\nxdebug.start_with_request=yes' > /etc/php/${PHP_VERSION}/apache2/conf.d/20-xdebug.ini"
        ;;
esac

# Start Apache
sudo service apache2 start

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

# Make a default SilverStripe .env file
echo "SS_DATABASE_CLASS='MySQLDatabase'" > .env
echo "SS_DATABASE_SERVER='127.0.0.1'" >> .env
echo "SS_DATABASE_USERNAME='${PROJECT_NAME}'" >> .env
echo "SS_DATABASE_PASSWORD='${MYSQL_PASSWORD}'" >> .env
echo "SS_DATABASE_NAME='${PROJECT_NAME}'" >> .env
echo "SS_ENVIRONMENT_TYPE='dev'" >> .env
echo "SS_DEFAULT_ADMIN_USERNAME='admin'" >> .env
echo "SS_DEFAULT_ADMIN_PASSWORD='password'" >> .env
echo "SS_ERROR_LOG='log/error.log'" >> .env
echo "SS_TEMP_PATH='/tmp/silverstripe-cache'" >> .env

# Make some aliases for the user
echo "alias dev-build='vendor/bin/sake dev/build'" >> ~/.bashrc
echo "alias flush='rm -rf /tmp/silverstripe-cache/.'" >> ~/.bashrc
echo "alias expose='composer vendor-expose'" >> ~/.bashrc
echo "alias watch='npm run dev'" >> ~/.bashrc
echo "alias build='npm run production'" >> ~/.bashrc
echo "alias sake='vendor/bin/sake'" >> ~/.bashrc

# Add an echo to the ~/.bashrc file to remind the user to run the Laravel server
echo "echo -e 'You are currently running a \033[1;34mSilverstripe\033[0m specialisation container.'" >> ~/.bashrc
echo "echo -e 'Useful commands:'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mdev-build\033[0m: Run the Silverstripe dev/build command'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mflush\033[0m: Clear the Silverstripe cache'" >> ~/.bashrc
echo "echo -e '  - \033[1;34msake\033[0m: Shortcut for the Silverstripe sake command (vendor/bin/sake)'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mexpose\033[0m: Expose vendor files to the webroot'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mwatch\033[0m: Watch assets for changes'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mbuild\033[0m: Build assets for production'" >> ~/.bashrc
echo "echo -e 'Included scripts:'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mimport-db\033[0m: Import a database dump into the database'" >> ~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: import-db <sql_file>'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mexport-db\033[0m: Export the database into a dump file'" >> ~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: export-db <dump_file>'" >> ~/.bashrc
echo "echo -e '  - \033[1;34mclear-db\033[0m: Remove all tables from the database'" >> ~/.bashrc
echo "echo -e '    - \033[1;90mUsage\033[0m: clear-db <dump_file>'" >> ~/.bashrc