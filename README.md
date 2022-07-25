# laptop

Tools for setting up a new Mac laptop for development

## Background

I've heard other developers talk about how they have a setup script that they use to migrate from one development machine to another. A quick Google search turned up the [thoughtbot/laptop](https://github.com/thoughtbot/laptop) repo. I looked through the [source](https://github.com/thoughtbot/laptop/blob/main/mac) and decided I wanted something slightly different. The thoughtbot script requires you to use `zsh`, but I wanted to use `bash`. It also installs some tools that I don't use, and I wanted to add others, so I customized it to fit my needs.

## Running the mac.sh script

The main setup script is in `mac.sh`. This script and the installation instructions below are largely copied from [https://github.com/thoughtbot/laptop](https://github.com/thoughtbot/laptop).

### Customize

To customize your local version, edit the `.laptop.local` file. It will be run by the `mac.sh` script as the final step. This is a good place to add the various apps and CLIs that you like to use for development.

### Install

Fork and clone this repo, then `cd` into it.

Review the script (avoid running scripts you haven't read!):

```sh
less mac.sh
```

Execute the downloaded script:

```sh
sh mac.sh 2>&1 | tee ~/laptop.log
```

Optionally, review the log:

```sh
less ~/laptop.log
```

### VS Code

I use Visual Studio Code as my IDE, and fortunately it has a [Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync) feature that helps when moving to a new machine.

## Dotfiles

Dotfiles are configuration files for various tools, such as `.bash_profile` for the bash shell. Most likely, you've already made your own modifications to various dotfiles, and you will want to take these with you when setting up a new machine.

Once you've run the `mac.sh` installation script, you will have `rcm` installed in your terminal. This is a management tool that allows you to locate your dotfiles in a folder outside of your home folder, which makes it easier to copy them back and forth to your own git repository.

Follow these steps to manage your dotfiles:

1. Replace the files in the `dotfiles` folder with your own custom dotfiles. Remove leading `.`s in the filenames. However, don't remove `dotfiles/rcrc`. This is a configuration file for `rcrc`, which manages the configuration for `rcm`.
2. Update `dotfiles/rcrc` by replacing `DOTFILES_DIRS` with the local path to your `dotfiles` folder in this repo.
3. Run this command: `env RCRC=/<path_to_this_repo_on_your_machine>/dotfiles/rcrc rcup`

To see the list of dotfiles that are now symlinked to your home folder, run: `lsrc`. You'll see something like this:

```
/Users/alexnitta/.bash_profile:/Users/alexnitta/code/laptop/dotfiles/bash_profile
/Users/alexnitta/.bashrc:/Users/alexnitta/code/laptop/dotfiles/bashrc
/Users/alexnitta/.gitconfig:/Users/alexnitta/code/laptop/dotfiles/gitconfig
/Users/alexnitta/.rcrc:/Users/alexnitta/code/laptop/dotfiles/rcrc
```

You can verify this by `cd`ing to your home directory, then running `ls -la . | grep "\->"` to see only the symlinks.

Any time you add a new dotfile in your local repo, you can run `rcup` to add a symlink for it. Push your changes up to GitHub, and now you have a reproducible dotfiles setup.
