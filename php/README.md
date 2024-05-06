# PHP

This directory contains the setup script and tools for the PHP toolkit in order to get started quickly with a customised development environment for generic PHP projects.

## Additional Environment Variables

The following environment variables can be used to customise the PHP setup script:

- `PHP_VERSION`: The version of PHP to install.

### Autodetecting PHP Version

If you do not specify the `PHP_VERSION` environment variable, the setup script will attempt to autodetect the latest versions of PHP to install. It does this by checking the following sources:

- [composer.json](https://getcomposer.org/doc/01-basic-usage.md#composer-json-project-setup)
  1. `config.platform.php`
  2. `require.php`

> [!NOTE]
> Be sure to specify the `REPO_BRANCH` environment variable if your versions differ from the default branch. Only the versions detected in the default branch will be used.

## Included Tools

The following tools are included in the Laravel setup script:

- [PHP](https://www.php.net/)
  - [Composer](https://getcomposer.org/)
    - [Laravel Installer](https://laravel.com/docs/8.x/installation)
  - [Required PHP Extensions](https://laravel.com/docs/8.x/deployment#server-requirements)
  - [xDebug](https://xdebug.org/)
