require 'bundler/setup'
require 'coffer/coin_installer'
require 'coffer/coins/feathercoin'
require 'pry'
require 'fileutils'

FileUtils.rm_rf '/tmp/coffer'

c = Coffer::Coin::Feathercoin.new

c.build

puts "Built: #{ c.executable_path }"

