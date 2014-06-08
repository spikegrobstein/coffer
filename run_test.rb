require 'bundler/setup'
require 'coffer/registry'
require 'coffer/installer'
require 'coffer/definition'
require File.join( File.dirname(__FILE__), 'coins' )

require 'pry'
require 'fileutils'

# cleanup
# FileUtils.rm_rf '/tmp/coffer'

c = Coffer::Coin::Feathercoin.new

installer = Coffer::Installer.new( c )
installer.install

puts "Built: #{ c.executable_path }"

