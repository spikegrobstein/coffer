require "coffer/version"
require 'coffer/coin'
require 'coffer/wallet'
require 'coffer/builder'
require 'coffer/client'
require 'coffer/registry'

module Coffer
  HOME_DIR = File.expand_path('~/.coffer')
  CACHE_DIR = File.join(HOME_DIR, 'cache')
  WALLET_DIR = File.join(HOME_DIR, 'wallets')
end
