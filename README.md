# laptop

Tools for setting up a new Mac laptop for development

## Resources

I've heard other developers talk about how they have a setup script that they use to migrate from one development machine to another. A quick Google search turned up the [thoughtbot/laptop](https://github.com/thoughtbot/laptop) repo. I looked through the [source](https://github.com/thoughtbot/laptop/blob/main/mac) and decided I wanted something slightly different.

## Managing dotfiles

Dotfiles are files like `.bash_profile` that customize your tools. There's a CLI called [`rcm`](https://github.com/thoughtbot/rcm) that allows you to set up a separate folder called `.dotfiles` for managing your dotfiles in a reproducible / migratable way.

If you've already made changes to your own dotfiles and want to move them to a new machine, you can follow [this section](http://thoughtbot.github.io/rcm/rcm.7.html#QUICK_START_FOR_EMPTY_DOTFILES_DIRECTORIES) of the tutorial to set up a `~/.dotfiles` directory and then move specific dotfiles into it. When following this tutorial, I got tripped up because I didn't realize all the commands had to be run from the home directory, i.e. from the `~` directory.

Here are the commands I ran:

```bash
# install rcm
$ brew install rcm

# Make sure you're in your home folder that contains your dotfiles
$ cd ~

# mkrc is installed along with rcm. It's purpose is to "bless files into a dotfiles managed by rcm."
# From what I can tell, this means it tells rcm "we're now going to manage these specific dotfiles."
# It moves the files from their usual location in `~` to a subfolder called `~/.dotfiles`.
$ mkrc .bashrc .gitconfig .bash_profile

# This seems to set up symlinks from the files that were just moved to `~/.dotfiles` to their original
# location in `~`. For example, `~/.bashrc` is now a symlink to `~/.dotfiles/.bashrc`.
$ rcup -v
```

After running these setup steps, you can list out the dotfiles that are being managed by `rcm` like this:

```bash
$ lsrc
/Users/alexnitta/.bash_profile:/Users/alexnitta/.dotfiles/bash_profile
/Users/alexnitta/.bashrc:/Users/alexnitta/.dotfiles/bashrc
/Users/alexnitta/.gitconfig:/Users/alexnitta/.dotfiles/gitconfig
```

Now you've got a subfolder of dotfiles that are managed by `rcm`, and you can follow [this step](http://thoughtbot.github.io/rcm/rcm.7.html#STANDALONE_INSTALLATION_SCRIPT) to make a script that will reproduce your setup on a new laptop.

```bash
$ cd ~/.dotfiles
$ env RCRC=/dev/null rcup -B 0 -g > install.sh
```

Now `~/.dotfiles` folder is a nice bundle of the dotfiles we care about for development purposes that contains its own install script.

## Running the setup script

Now that you've got the `~/.dotfiles` folder set up, you can execute the setup script. The setup script and the rest of this README are largely copied from [https://github.com/thoughtbot/laptop](https://github.com/thoughtbot/laptop).

## Install

Download the script:

```sh
curl --remote-name https://raw.githubusercontent.com/alexnitta/laptop/main/mac
```

Review the script (avoid running scripts you haven't read!):

```sh
less mac
```

Execute the downloaded script:

```sh
sh mac 2>&1 | tee ~/laptop.log
```

Optionally, review the log:

```sh
less ~/laptop.log
```
