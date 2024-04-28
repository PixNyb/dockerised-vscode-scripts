# Contributing

Contributions are more than welcome. Currently the project is based around my specific needs, but I would like to expand it to support more languages and toolkits.

If you would like to contribute to this project by adding new toolkits or languages, please follow the steps below:

1. Fork the repository
2. Create a new branch
3. Add your changes
4. Commit your changes
5. Push your changes to your fork
6. Create a pull request
7. Wait for the pull request to be reviewed
8. If the pull request is approved, it will be merged into the main branch

## Adding a New Toolkit or Language

To add a new toolkit or language, you can follow the steps below:

1. Create a new directory for the toolkit or language. The format should be `<language>/<toolkit>`. If you are adding a base language, the format should be `<language>/generic`.
2. Add a `initialise-vscode.sh` script to the directory. This script should contain the setup steps for the toolkit or language and will be run just before vscode starts. In here you can install additional requirements such as a database server, language-specific tools, and extensions.
   1. **Recommended:** Add a couple of handy aliases and a welcome message to the script. This will make it easier for the user to get started with the toolkit or language.
3. Add a `README.md` file to the directory. This file should contain information about the toolkit or language, how to use it, and any additional setup steps that may be required.
4. Optionally, you can add a `scripts` directory to the toolkit or language directory. This directory can contain additional scripts that can be used by the user. Such as a script to import a database or run tests.

## Testing

To test the setup script, you can use the mounted script method with the docker container. This will allow you to test the script in a local environment before submitting a pull request.

For example, to test the Laravel setup script:

```bash
docker run -it --rm -v /path/to/laravel/initialise-vscode.sh:/usr/local/bin/initialise-vscode.sh pixnyb/code
```

This command will run the setup script in the container and allow you to test the setup steps.