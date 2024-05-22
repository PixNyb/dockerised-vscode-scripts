# .NET

This directory contains the setup script and tools for the .NET toolkit in order to get started quickly with a customised development environment for generic .NET projects and solutions.

## Additional Environment Variables

The following environment variables can be used to customise the .NET setup script:

- `DOTNET_VERSION`: The version of .NET to install.

### Autodetecting Node.js Version

If you do not specify the `NODE_VERSION` environment variable, the setup script will attempt to autodetect the latest versions of Node.js to install. It does this by checking the following sources:

- [package.json](https://docs.npmjs.com/cli/v7/configuring-npm/package-json)
  1. `packageLockVersion`
     - The `packageLockVersion` is used to determine the required Node.js version based on the following mapping:
       - `1` -> `14.x`
       - `2` -> `18.x`
       - `3` -> `22.x`

> [!NOTE]
> Be sure to specify the `REPO_BRANCH` environment variable if your versions differ from the default branch. Only the versions detected in the default branch will be used.

## Included Tools

The following tools are included in the .NET setup script:

- [.NET](https://dotnet.microsoft.com/)
  - [NuGet](https://www.nuget.org/)
  - [MSBuild](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild)
