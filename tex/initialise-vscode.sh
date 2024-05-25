#!/bin/bash

# Add extension to the list of extensions
extensions=(
	"mathematic.vscode-latex"
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

# Install texlive, ChxTeX, and latexindent.pl
sudo apt-get update
sudo apt-get install -y texlive-full

# Set up the tex project
cd $PROJECT_FOLDER

echo "echo -e 'You are currently running a \033[1;90mTex\033[0m generic container.'" >>~/.bashrc
