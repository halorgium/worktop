# Worktop

Have a separate set of gems like `rvm` gemsets, but without rvm.

## Install

To install `worktop`, you need to download the script and source it.

Downloading is easy:

    $ mkdir $HOME/.scripts
    $ wget -O $HOME/.scripts/worktop.sh http://github.com/halorgium/worktop/raw/master/worktop.sh

Then install into your shell RC:

    export WORKTOP_DIR=$HOME/tmp/worktop
    source $HOME/.scripts/worktop.sh

## Usage

You can use `worktop` for messing around:

    $ worktop hax
    Changing to worktop [hax]
    $ gem list
    *** LOCAL GEMS ***

    $ gem install bundler
    Successfully installed bundler-1.0.0
    1 gem installed

    $ worktop --exit
    Leaving worktop [hax]

    $ worktop hax gem list
    changing to worktop [hax]

    *** LOCAL GEMS ***

    bundler (1.0.0)

You can put a `.worktoprc` in a directory and it will enable when you `cd` in.

An example is the following:

    rvm use 1.8.6
    worktop awsm

It will change to 1.8.6 and then use that `worktop` directory.

You can decide just to use `worktop` by itself.

## Motivation

I want `rvm` gemsets without `rvm`.

## Thanks

To rvm, for the hax for cd overriding.
