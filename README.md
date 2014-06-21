# Coffer

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'coffer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coffer

## Requirements

On ubuntu:

 * git
 * build-essential
 * libboost-all-dev
 * libssl-dev
 * libdb++-dev
 * libminiupnpc-dev
 * autoconf

Probably ruby 2.x

## Usage

TODO: Write usage instructions here

## Goals

 * create searchable list of wallets
 * install wallet by name from most recent code-base
 * compile in docker container

Post compilation should create a "home" directory for the wallet with the following structure

  ~/.coffer/wallets/
    feathercoin/bin/feathercoind
    feathercoin/.feathercoind/feathercoin.conf
    feathercoin/.feathercoind/<data files>

When starting the wallet, give container working directory of the above home directory. execute wallet. name container accordingly (`coffer-wallet-<walletname>`?)

run wallet as unprivileged user in container (`coffer`)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
