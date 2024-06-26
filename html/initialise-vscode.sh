#!/bin/bash

# Add extension to the list of extensions
extensions=(
	"christian-kohler.path-intellisense"
	"formulahendry.auto-close-tag"
	"formulahendry.auto-rename-tag"
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

PUBLIC_FOLDER=${PUBLIC_FOLDER-}
PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Check if the PUBLIC_FOLDER exists, if not, set to the PROJECT_FOLDER
if [ -z "$PUBLIC_FOLDER" ]; then
	PUBLIC_FOLDER=$PROJECT_FOLDER
fi

# Install apache2 and enable it
sudo apt-get update
sudo apt-get install -y apache2

# Point apache to $PUBLIC_FOLDER
chmod 755 ~
sudo sed -i "s|/var/www/html|$PUBLIC_FOLDER|g" /etc/apache2/sites-available/000-default.conf

# Add the directory configuration to apache
sudo sed -i "s|</VirtualHost>|    <Directory $PUBLIC_FOLDER>\n        Options Indexes FollowSymLinks\n        AllowOverride All\n        Require all granted\n    </Directory>\n</VirtualHost>|g" /etc/apache2/sites-available/000-default.conf

# Make apache run under the current user
USER=$(whoami)
sudo sed -i "s|export APACHE_RUN_USER=www-data|export APACHE_RUN_USER=$USER|g" /etc/apache2/envvars
sudo sed -i "s|export APACHE_RUN_GROUP=www-data|export APACHE_RUN_GROUP=$USER|g" /etc/apache2/envvars

# Enable Apache mod_rewrite
sudo a2enmod rewrite

# Start Apache
sudo service apache2 start

# Set up the HTML project
cd $PROJECT_FOLDER

echo "echo -e 'You are currently running a \033[1;36mHTML\033[0m generic container.'" >>~/.bashrc
