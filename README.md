# Dockerised Visual Studio Code Scripts

This repository contains various setup scripts and tools for the [Dockerised Visual Studio Code](https://github.com/PixNyb/dockerised-vscode) project in order to get started quickly with a customised development environment for various programming languages and toolkits.

## Usage

To use these scripts, you can either mount the `initialise-vscode.sh` script to the container or use the `INIT_SCRIPT_URL` environment variable to download the script from inside the container.

### Mounting the Script

You can mount the `initialise-vscode.sh` script to the container by adding the following volume to your `docker-compose.yml` file:

```yaml
services:
  code:
    image: pixnyb/code
    volumes:
      - /path/to/initialise-vscode.sh:/usr/local/bin/initialise-vscode.sh
```

### Using the Environment Variable

You can use the `INIT_SCRIPT_URL` environment variable to download the script from inside the container. For example:

```yaml
services:
  code:
    image: pixnyb/code
    environment:
      - INIT_SCRIPT_URL=https://example.com/init.sh
```

## Example

The following output will create a docker container with a customised development environment for a Laravel project:

```yaml
services:
  code:
    image: pixnyb/code
    environment:
      - VSCODE_KEYRING_PASS=password
      - GH_TOKEN=<...>
      - REPO_URL=<...>
      - INIT_SCRIPT_URL=https://raw.githubusercontent.com/PixNyb/dockerised-vscode-scripts/main/php/laravel/initialise-vscode.sh
```

## Supported Languages and Toolkits

- [PHP](php)
  - [Laravel](php/laravel)
  - [Silverstripe](php/silverstripe)
- [Node.js](node)
- [.NET](dotnet)

## Contributing

If you would like to contribute to this project, please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.
