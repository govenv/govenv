

# Go Version Management: govenv

govenv aims to be as simple as possible and follow the already estabilished
successful version management model of [pyenv](https://github.com/yyuu/pyenv) and [rbenv](https://github.com/rbenv/rbenv).

This project was cloned from [pyenv](https://github.com/yyuu/pyenv) and modified for Go.

[![asciicast](https://asciinema.org/a/ci4otj2507p1w7h91c0s8bjcu.png)](https://asciinema.org/a/ci4otj2507p1w7h91c0s8bjcu)

### govenv _does..._

* Let you **change the global Go version** on a per-user basis.
* Provide support for **per-project Go versions**.
* Allow you to **override the Go version** with an environment
  variable.
* Search commands from **multiple versions of Go at a time**.


### govenv compared to others:

* https://github.com/pwoolcoc/govenv depends on Python,
* https://github.com/crsmithdev/govenv depends on Go,
* https://github.com/moovweb/gvm is a different approach of the problem that's modeled after `nvm`. `govenv` is more simplified.


----


## Table of Contents

* **[How It Works](#how-it-works)**
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Go Version](#choosing-the-go-version)
  * [Locating the Go Installation](#locating-the-go-installation)
* **[Installation](#installation)**
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
    * [Advanced Configuration](#advanced-configuration)
    * [Uninstalling Go Versions](#uninstalling-go-versions)
* **[Command Reference](#command-reference)**
* **[Development](#development)**
  * [Version History](#version-history)
  * [License](#license)


----


## How It Works

At a high level, govenv intercepts Go commands using shim
executables injected into your `PATH`, determines which Go version
has been specified by your application, and passes your commands along
to the correct Go installation.

### Understanding PATH

When you run all the variety of Go commands using  `go`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

govenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.govenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, govenv maintains shims in that
directory to match every `go` command across every installed version
of Go.

Shims are lightweight executables that simply pass your command along
to govenv. So with govenv installed, when you run `go` your
operating system will do the following:

* Search your `PATH` for an executable file named `go`
* Find the govenv shim named `go` at the beginning of your `PATH`
* Run the shim named `go`, which in turn passes the command along to
  govenv

### Choosing the Go Version

When you execute a shim, govenv determines which Go version to use by
reading it from the following sources, in this order:

1. The `GOVENV_VERSION` environment variable (if specified). You can use
   the [`govenv shell`](https://github.com/syndbg/govenv/blob/master/COMMANDS.md#govenv-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.go-version` file in the current
   directory (if present). You can modify the current directory's
   `.go-version` file with the [`govenv local`](https://github.com/syndbg/govenv/blob/master/COMMANDS.md#govenv-local)
   command.

3. The first `.go-version` file found (if any) by searching each parent
   directory, until reaching the root of your filesystem.

4. The global `~/.govenv/version` file. You can modify this file using
   the [`govenv global`](https://github.com/syndbg/govenv/blob/master/COMMANDS.md#govenv-global) command. If the global version
   file is not present, govenv assumes you want to use the "system"
   Go. (In other words, whatever version would run if govenv isn't present in
   `PATH`.)

**NOTE:** You can activate multiple versions at the same time, including multiple
versions of Go simultaneously or per project.

### Locating the Go Installation

Once govenv has determined which version of Go your application has
specified, it passes the command along to the corresponding Go
installation.

Each Go version is installed into its own directory under
`~/.govenv/versions`.

For example, you might have these versions installed:

* `~/.govenv/versions/1.6.1/`
* `~/.govenv/versions/1.6.2/`

As far as govenv is concerned, version names are simply the directories in
`~/.govenv/versions`.

## Installation

If you're on Mac OS X, consider [installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of govenv and make it
easy to fork and contribute any changes back upstream.

1. **Check out govenv where you want it installed.**
   A good place to choose is `$HOME/.govenv` (but you can install it somewhere else).

        $ git clone https://github.com/syndbg/govenv.git ~/.govenv


2. **Define environment variable `GOVENV_ROOT`** to point to the path where
   govenv repo is cloned and add `$GOVENV_ROOT/bin` to your `$PATH` for access
   to the `govenv` command-line utility.

        $ echo 'export GOVENV_ROOT="$HOME/.govenv"' >> ~/.bash_profile
        $ echo 'export PATH="$GOVENV_ROOT/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.
    **Ubuntu note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.

3. **Add `govenv init` to your shell** to enable shims and autocompletion.
   Please make sure `eval "$(govenv init -)"` is placed toward the end of the shell
   configuration file since it manipulates `PATH` during the initialization.

        $ echo 'eval "$(govenv init -)"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.
    **Ubuntu note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.
    
    **General warning**: There are some systems where the `BASH_ENV` variable is configured
    to point to `.bashrc`. On such systems you should almost certainly put the abovementioned line
    `eval "$(govenv init -)` into `.bash_profile`, and **not** into `.bashrc`. Otherwise you
    may observe strange behaviour, such as `govenv` getting into an infinite loop.
    See pyenv's issue [#264](https://github.com/yyuu/pyenv/issues/264) for details.

4. **Restart your shell so the path changes take effect.**
   You can now begin using govenv.

        $ exec $SHELL

5. **Install Go versions into `$GOVENV_ROOT/versions`.**
   For example, to download and install Go 1.6.2, run:

        $ govenv install 1.6.2

   **NOTE:** It downloads and places the prebuilt Go binaries provided by Google.

#### Upgrading

If you've installed govenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of govenv, use `git pull`:

    $ cd ~/.govenv
    $ git pull

To upgrade to a specific release of govenv, check out the corresponding tag:

    $ cd ~/.govenv
    $ git fetch
    $ git tag
    v20160417
    $ git checkout v20160417

### Uninstalling govenv

The simplicity of govenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** govenv managing your Go versions, simply remove the
  `govenv init` line from your shell startup configuration. This will
  remove govenv shims directory from PATH, and future invocations like
  `govenv` will execute the system Go version, as before govenv.

  `govenv` will still be accessible on the command line, but your Go
  apps won't be affected by version switching.

2. To completely **uninstall** govenv, perform step (1) and then remove
   its root directory. This will **delete all Go versions** that were
   installed under `` `govenv root`/versions/ `` directory:

        rm -rf `govenv root`

   If you've installed govenv using a package manager, as a final step
   perform the govenv package removal. For instance, for Homebrew:

        brew uninstall govenv

## Command Reference

### Homebrew on Mac OS X

You can also install govenv using the [Homebrew](http://brew.sh)
package manager for Mac OS X.

    $ brew update
    $ brew install govenv

To upgrade govenv in the future, use `upgrade` instead of `install`.

After installation, you'll need to add `eval "$(govenv init -)"` to your profile (as stated in the caveats displayed by Homebrew — to display them again, use `brew info govenv`). You only need to add that to your profile once.

Then follow the rest of the post-installation steps under "Basic GitHub Checkout" above, starting with #4 ("restart your shell so the path changes take effect").

### Advanced Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`govenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `govenv init` actually does:

1. **Sets up your shims path.** This is the only requirement for govenv to
   function properly. You can do this by hand by prepending
   `~/.govenv/shims` to your `$PATH`.

2. **Installs autocompletion.** This is entirely optional but pretty
   useful. Sourcing `~/.govenv/completions/govenv.bash` will set that
   up. There is also a `~/.govenv/completions/govenv.zsh` for Zsh
   users.

3. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `govenv rehash` manually.

4. **Installs the sh dispatcher.** This bit is also optional, but allows
   govenv and plugins to change variables in your current shell, making
   commands like `govenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `govenv` to be a real script rather than a
   shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run `govenv init -`.


### Uninstalling Go Versions

As time goes on, you will accumulate Go versions in your
`~/.govenv/versions` directory.

To remove old Go versions, `govenv uninstall` command to automate
the removal process.

Alternatively, simply `rm -rf` the directory of the version you want
to remove. You can find the directory of a particular Go version
with the `govenv prefix` command, e.g. `govenv prefix 1.6.2`.


----


## Command Reference

See [COMMANDS.md](COMMANDS.md).


----

## Environment variables

You can affect how govenv operates with the following settings:

name | default | description
-----|---------|------------
`GOVENV_VERSION` | | Specifies the Go version to be used.<br>Also see [`govenv shell`](#govenv-shell)
`GOVENV_ROOT` | `~/.govenv` | Defines the directory under which Go versions and shims reside.<br>Also see `govenv root`
`GOVENV_DEBUG` | | Outputs debug information.<br>Also as: `govenv --debug <subcommand>`
`GOVENV_HOOK_PATH` | Colon-separated list of paths searched for govenv hooks.
`GOVENV_DIR` | `$PWD` | Directory to start searching for `.go-version` files.

## Development

The govenv source code is [hosted on
GitHub](https://github.com/syndbg/govenv).  It's clean, modular,
and easy to understand, even if you're not a shell hacker. (I hope)

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats/test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/syndbg/govenv/issues).
