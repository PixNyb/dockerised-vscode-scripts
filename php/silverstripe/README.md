# Silverstripe

This directory contains the setup script and tools for the Silverstripe toolkit in order to get started quickly with a customised development environment for Silverstripe >=4 projects.

## Additional Environment Variables

The following environment variables can be used to customise the Laravel setup script:

- `PHP_VERSION`: The version of PHP to install.
- `NODE_VERSION`: The version of Node.js to install.

### Autodetecting PHP and Node.js Versions

If you do not specify the `PHP_VERSION` or `NODE_VERSION` environment variables, the setup script will attempt to autodetect the latest versions of PHP and Node.js to install. It does this by checking the following sources:

- [composer.json](https://getcomposer.org/doc/01-basic-usage.md#composer-json-project-setup)
  1. `config.platform.php`
  2. `require.php`
  3. `silverstripe/recipe-cms`
     - The installed recipe-cms version is used to determine the required PHP version based on the [Packagist](https://packagist.org/packages/silverstripe/recipe-cms) page.
  4. `silverstripe/framework`
     - The installed framework version is used to determine the required PHP version based on the [Packagist](https://packagist.org/packages/silverstripe/framework) page.

- [package.json](https://docs.npmjs.com/cli/v7/configuring-npm/package-json)
  1. `packageLockVersion`
     - The `packageLockVersion` is used to determine the required Node.js version based on the following mapping:
       - `1` -> `14.x`
       - `2` -> `18.x`
       - `3` -> `22.x`

> [!NOTE]
> Be sure to specify the `REPO_BRANCH` environment variable if your versions differ from the default branch. Only the versions detected in the default branch will be used.

## Included Tools

The following tools are included in the Silverstripe setup script:

- [PHP](https://www.php.net/)
  - [Composer](https://getcomposer.org/)
  - [Required PHP Extensions](https://docs.silverstripe.org/en/5/developer_guides/templates/requirements/)
  - [xDebug](https://xdebug.org/)
- [Node.js](https://nodejs.org/)
  - [NPM](https://www.npmjs.com/)
  - [Yarn](https://yarnpkg.com/)
- [MariaDB](https://mariadb.org/)

## Included Aliases

The following aliases are included in the Silverstripe setup script:

- `dev-build`: Run the Silverstripe dev/build command
- `flush`: Clear the Silverstripe cache
- `sake`: Shortcut for the Silverstripe sake command (`vendor/bin/sake`)
- `expose`: Expose vendor files to the webroot
- `watch`: Watch assets for changes
- `build`: Build assets for production

## Included Scripts

The following scripts are included in the Silverstripe setup script:

- `import-db`: Import a database dump into the database
  - Usage: `import-db /path/to/dump.sql`
- `export-db`: Export the database into a dump file
  - Usage: `export-db /path/to/dump.sql`
- `clear-db`: Remove all tables from the database
  - Usage: `clear-db`
