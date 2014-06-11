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
      coin = Coffer::Registry.instance.find( coin )

      if coin.nil?
        warn "Unable to find a coin with a name or symbol of #{ coin }"
      end

      warn "installing coin: #{ coin.name } (#{coin.symbol})"

      installer = Coffer::Installer.new(coin)
      if installer.install
        puts "success!"
      else
        puts "Failed to install coin..."
      end
    end

    desc "start <coin>", "Start the given coin."
    def start(coin)
      coin = Coffer::Registry.instance.find(coin)

      if coin.nil?
        warn "Unable to find a coin with a name or symbol of #{ coin }"
      end

      coin.start
    end

    desc "stop <coin>", "Stop the given coin."
    def stop(coin)
      coin = Coffer::Registry.instance.find(coin)

      if coin.nil?
        warn "Unable to find a coin with a name or symbol of #{ coin }"
      end

      coin.stop
    end
  end
end
