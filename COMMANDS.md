# Command Reference

Like `git`, the `govenv` command delegates to subcommands based on its
first argument. 

The most common subcommands are:

* [`govenv commands`](#govenv-commands)
* [`govenv local`](#govenv-local)
* [`govenv global`](#govenv-global)
* [`govenv shell`](#govenv-shell)
* [`govenv install`](#govenv-install)
* [`govenv uninstall`](#govenv-uninstall)
* [`govenv rehash`](#govenv-rehash)
* [`govenv version`](#govenv-version)
* [`govenv versions`](#govenv-versions)
* [`govenv which`](#govenv-which)
* [`govenv whence`](#govenv-whence)

## `govenv commands`

Lists all available govenv commands.

## `govenv local`

Sets a local application-specific Go version by writing the version
name to a `.go-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `GOVENV_VERSION` environment variable or with the `govenv shell`
command.

```shell
> govenv local 1.6.1
```

When run without a version number, `govenv local` reports the currently
configured local version. You can also unset the local version:


```shell
> govenv local --unset
```

Previous versions of govenv stored local version specifications in a
file named `.govenv-version`. For backwards compatibility, govenv will
read a local version specified in an `.govenv-version` file, but a
`.go-version` file in the same directory will take precedence.

### `govenv local` (advanced)

You can specify local Go version. 

```shell
> govenv local 1.5.4

# Showcase
> govenv versions
  system
  * 1.5.4 (set by /Users/govenv/path/to/project/.go-version)

> govenv version
1.5.4 (set by /Users/govenv/path/to/project/.go-version)

> go version

go version go1.5.4 darwin/amd64
```

## `govenv global`

Sets the global version of Go to be used in all shells by writing
the version name to the `~/.govenv/version` file. This version can be
overridden by an application-specific `.go-version` file, or by
setting the `GOVENV_VERSION` environment variable.

```shell
> govenv global 1.5.4

# Showcase
> govenv versions
  system
  * 1.5.4 (set by /Users/govenv/.govenv/version)

> govenv version
1.5.4 (set by /Users/govenv/.govenv/version)

> go version
go version go1.5.4 darwin/amd64
```

The special version name `system` tells govenv to use the system Go
(detected by searching your `$PATH`).

When run without a version number, `govenv global` reports the
currently configured global version.

## `govenv shell`

Sets a shell-specific Go version by setting the `GOVENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

```shell
> govenv shell 1.5.4
```

When run without a version number, `govenv shell` reports the current
value of `GOVENV_VERSION`. You can also unset the shell version:

```shell
> govenv shell --unset
```

Note that you'll need govenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`GOVENV_VERSION` variable yourself:

```shell
> export GOVENV_VERSION=1.5.4

```

## `govenv install`

Install a Go version (using `go-build`).

```shell
> govenv install

Usage: govenv install [-f] [-kvp] <version>
        govenv install [-f] [-kvp] <definition-file>
        govenv install -l|--list

  -l/--list             List all available versions
  -f/--force            Install even if the version appears to be installed already
  -s/--skip-existing    Skip the installation if the version appears to be installed already

  go-build options:

  -k/--keep        Keep source tree in $GOVENV_BUILD_ROOT after installation
                    (defaults to $GOVENV_ROOT/sources)
  -v/--verbose     Verbose mode: print compilation status to stdout
  -p/--patch       Apply a patch from stdin before building
  -g/--debug       Build a debug version
```

## `govenv uninstall`

Uninstall a specific Go version.

```shell
> govenv uninstall
Usage: govenv uninstall [-f|--force] <version>

    -f  Attempt to remove the specified version without prompting
        for confirmation. If the version does not exist, do not
        display an error message.
```

## `govenv rehash`

Installs shims for all Go binaries known to govenv (i.e.,
`~/.govenv/versions/*/bin/*`).
Run this command after you install a new
version of Go, or install a package that provides binaries.

```shell
> govenv rehash
```

## `govenv version`

Displays the currently active Go version, along with information on
how it was set.

```shell
> govenv version
1.5.4 (set by /Users/govenv/.govenv/version)
```

## `govenv versions`

Lists all Go versions known to govenv, and shows an asterisk next to
the currently active version.

```shell
> govenv versions
  1.4.0
  1.4.1
  1.4.2
  1.4.3
  1.5.0
  1.5.1
  1.5.2
  1.5.3
  1.5.4
  1.6.0
* 1.6.1 (set by /Users/govenv/.govenv/version)
  1.6.2
```

## `govenv which`

Displays the full path to the executable that govenv will invoke when
you run the given command.

```shell
> govenv which gofmt
/home/govenv/.govenv/versions/1.6.1/bin/gofmt
```

## `govenv whence`

Lists all Go versions with the given command installed.

```shell
> govenv whence go
1.3.0
1.3.1
1.3.2
1.3.3
1.4.0
1.4.1
1.4.2
1.4.3
1.5.0
1.5.1
1.5.2
1.5.3
1.5.4
1.6.0
1.6.1
1.6.2
```
