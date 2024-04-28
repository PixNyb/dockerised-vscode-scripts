# Laravel

This directory contains the setup script and tools for the Laravel toolkit in order to get started quickly with a customised development environment for Laravel projects.

## Additional Environment Variables

The following environment variables can be used to customise the Laravel setup script:

- `PHP_VERSION`: The version of PHP to install.
- `NODE_VERSION`: The version of Node.js to install.

### Autodetecting PHP and Node.js Versions

If you do not specify the `PHP_VERSION` or `NODE_VERSION` environment variables, the setup script will attempt to autodetect the latest versions of PHP and Node.js to install. It does this by checking the following sources:

- [composer.json](https://getcomposer.org/doc/01-basic-usage.md#composer-json-project-setup)
  1. `config.platform.php`
  2. `require.php`
  3. `laravel/framework`
     - The installed framework version is used to determine the required PHP version based on the [Packagist](https://packagist.org/packages/laravel/framework) page.

- [package.json](https://docs.npmjs.com/cli/v7/configuring-npm/package-json)
  1. `packageLockVersion`
     - The `packageLockVersion` is used to determine the required Node.js version based on the following mapping:
       - `1` -> `14.x`
       - `2` -> `18.x`
       - `3` -> `22.x`

> [!NOTE]
> Be sure to specify the `REPO_BRANCH` environment variable if your versions differ from the default branch. Only the versions detected in the default branch will be used.

## Included Tools

The following tools are included in the Laravel setup script:

- [PHP](https://www.php.net/)
  - [Composer](https://getcomposer.org/)
    - [Laravel Installer](https://laravel.com/docs/8.x/installation)
  - [Required PHP Extensions](https://laravel.com/docs/8.x/deployment#server-requirements)
  - [xDebug](https://xdebug.org/)
- [Node.js](https://nodejs.org/)
  - [NPM](https://www.npmjs.com/)
  - [Yarn](https://yarnpkg.com/)
- [MariaDB](https://mariadb.org/)

> [!NOTE]
> xDebug currently is not installed, this will be added in a future update.

## Included Aliases

The following aliases are included in the Laravel setup script:

- `serve`: Run the Laravel development server
- `migrate`: Run the Laravel database migrations
- `seed`: Run the Laravel database seeders
- `artisan`: Shortcut for the artisan command (`php artisan`)
- `tinker`: Open Laravel tinker
- `watch`: Watch assets for changes
- `build`: Build assets for production

## Included Scripts

The following scripts are included in the Laravel setup script:

- `import-db`: Import a database dump into the database
  - Usage: `import-db /path/to/dump.sql`
- `export-db`: Export the database into a dump file
  - Usage: `export-db /path/to/dump.sql`