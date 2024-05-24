#!/bin/bash

# Set the dotnet version
DOTNET_VERSION=${DOTNET_VERSION:-dotnet-sdk-8.0}
PROJECT_FOLDER=${PROJECT_FOLDER:-~/project}
PROJECT_NAME=${PROJECT_NAME:-project}
PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/[^a-zA-Z0-9]/_/g')

VALID_DOTNET_PREFIXES=("aspnetcore-runtime-" "dotnet-runtime-" "dotnet-sdk-")

# The DOTNET_VERSION variable must be in the format (aspnetcore-runtime|dotnet-runtime|dotnet-sdk)-[0-9].[0-9].
# Format the DOTNET_VERSION variable if it is not in the correct format.
valid_dotnet_version=false
for prefix in "${VALID_DOTNET_PREFIXES[@]}"; do
	if [[ ${DOTNET_VERSION} =~ ^${prefix}[0-9]+\.[0-9]+$ ]]; then
		valid_dotnet_version=true
		break
	fi
done

if [[ ! $valid_dotnet_version ]]; then
	if [[ ${DOTNET_VERSION} =~ ^[0-9]+\.[0-9]+$ ]]; then
		DOTNET_VERSION="dotnet-sdk-$DOTNET_VERSION"
	else
		echo "Invalid .NET version. Please use the format (aspnetcore-runtime|dotnet-runtime|dotnet-sdk)-[0-9].[0-9]."
		exit 1
	fi
fi

sudo add-apt-repository ppa:dotnet/backports -y

source /etc/os-release
wget https://packages.microsoft.com/config/$ID/$VERSION_ID/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update -y

sudo apt install -y $DOTNET_VERSION

# Set up the .NET project
cd $PROJECT_FOLDER

# If there is a project or solution file, use it
if [[ -f *.csproj ]]; then
	dotnet restore
elif [[ -f *.sln ]]; then
	dotnet restore
fi

echo "echo -e 'You are currently running a \033[1;31m.NET\033[0m generic container.'" >>~/.bashrc




