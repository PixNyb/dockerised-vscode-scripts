#!/bin/bash

# Set the Node.js version
NODE_VERSION=${NODE_VERSION-}
PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

curdir=$(pwd)
cd $PROJECT_FOLDER
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

# Set up the Node.js project
cd $PROJECT_FOLDER

# If the project contains a package-lock.json file, install the dependencies
if [ -f package-lock.json ]; then
	npm install &
fi

# If the project contains a yarn.lock file, install the dependencies
if [ -f yarn.lock ]; then
	yarn install &
fi

echo "echo -e 'You are currently running a \033[1;31mNode.js\033[0m generic container.'" >>~/.bashrc
