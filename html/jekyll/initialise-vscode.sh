#!/bin/bash

# Add extension to the list of extensions
extensions=(
)

IFS=','
EXTENSION_LIST=${extensions[*]} /usr/local/bin/install-extensions.sh
unset IFS

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
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >>~/.bashrc
echo 'eval "$(rbenv init -)"' >>~/.bashrc

# Reload the shell to apply rbenv to the current session
source ~/.bashrc

# Ensure rbenv is correctly initialized
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

RUBY_VERSION=$(rbenv install -l | grep -v - | tail -1)

# Install Ruby
rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION

# Install bundler
gem install jekyll bundler

# Set up the HTML project
cd $PROJECT_FOLDER

# If possible, run the Jekyll server
if [[ -f "_config.yml" ]]; then
	bundle install
	bundle exec jekyll serve --host 0.0.0.0 &
fi

echo "echo -e 'You are currently running a \033[1;36mJekyll\033[0m generic container.'" >>~/.bashrc
