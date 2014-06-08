require 'bundler/setup'
require 'coffer/registry'
require 'coffer/installer'
require 'coffer/definition'

require 'pry'
require 'fileutils'

# cleanup
# FileUtils.rm_rf '/tmp/coffer'

Coffer::Registry.instance

c = Coffer::Coin::Feathercoin.new

installer = Coffer::Installer.new( c )
installer.install

puts "Built: #{ c.executable_path }"

