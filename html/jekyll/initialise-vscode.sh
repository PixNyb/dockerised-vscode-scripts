#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Set the environment variables for composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Download Ruby, RubyGems, GCC, Make, and other dependencies
sudo apt update
sudo apt-get install -y ruby-full build-essential zlib1g-dev \
	liblzma-dev libsqlite3-dev
sudo gem install jekyll bundler

# Set up the HTML project
cd $PROJECT_FOLDER

# If possible, run the Jekyll server
if [[ -f "_config.yml" ]]; then
	bundle install
	bundle exec jekyll serve --host
fi

echo "echo -e 'You are currently running a \033[1;36mJekyll\033[0m generic container.'" >>~/.bashrc
