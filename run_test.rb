require 'bundler/setup'
require 'coffer/registry'
require 'coffer/definition'
require File.join( File.dirname(__FILE__), 'coins' )

require 'pry'
require 'fileutils'

# cleanup
FileUtils.rm_rf '/tmp/coffer'

c = Coffer::Coin::Feathercoin.new

c.build

puts "Built: #{ c.executable_path }"

