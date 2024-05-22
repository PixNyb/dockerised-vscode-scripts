#!/bin/bash

PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

# Set the environment variables for composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Update system packages
sudo apt update

# Install dependencies for rbenv and Ruby
sudo apt-get install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

# Install rbenv and ruby-build plugin
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Add rbenv to bash so that it loads every time you open a Terminal
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >>~/.bashrc
source ~/.bashrc

# Ensure rbenv is correctly initialized
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby
rbenv install 2.7.2
rbenv global 2.7.2

# Install bundler
gem install jekyll bundler

# Set up the HTML project
cd $PROJECT_FOLDER

# If possible, run the Jekyll server
if [[ -f "_config.yml" ]]; then
	bundle install
	bundle exec jekyll serve --host
fi

echo "echo -e 'You are currently running a \033[1;36mJekyll\033[0m generic container.'" >>~/.bashrc
