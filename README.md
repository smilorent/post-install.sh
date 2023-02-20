# post-install.sh

This is a simple POSIX-compatible script designed to perform post-install actions (i.e. symbolic linking of dotfiles, running of executable scripts) on Unix-like environments. These actions are grouped in modules which can be deployed individually or collectively.

Structurally, each module directory should contain the following:
- a `scripts` subdirectory containing executable scripts;
- a `dotfiles` subdirectory containing configuration files;
- a `symlink.conf` file describing the paths which should be linked to these files.

A working sample module is provided under `modules/sample`.

## Usage

To use this script, you must firstly clone the repository to your machine:

```bash
git clone https://github.com/smilorent/post-install.sh.git
```

To deploy the `sample` module, run:

```bash
./post-install.sh sample
```

Additional modules can be deployed in the same session by passing them as extra arguments to `post-install.sh`.

## Features

This script includes the following features:

- argument-based approach for specifying which modules to provision;
- symbolic linking of dotfiles as specified in each module's `symlinks.conf` file;
- running of executable scripts found within each module's `scripts` directory;
- logging to both console and to files in the `output` directory.

## Contributions

Contributions to this project are welcome! If you find a bug or have a suggestion for an improvement, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
