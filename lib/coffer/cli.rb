require 'thor'
require 'coffer'
require 'pry'

module Coffer
  class CLI < Thor
    desc "list", "List all coins"
    def list
      Coffer::Registry.instance.coins.each do |coin|
        puts "%-20s (%s)" % [ coin.name, coin.symbol ]
      end
    end

    desc "search", "Search for coins"
    def search
      warn "not implemented"
    end

    desc "install <coin>", "Install the given coin."
    def install(coin)
      warn "installing coin."
    end
  end
end
