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

    def self.load_coins
      Coffer::Registry.instance.coins.each do |coin|
        # define actions:
        # coffer <coin> <action>
        block = Proc.new do |*action|
          coin.call_rpc(*action)
        end

        desc "#{ coin.name.downcase } <action> [ <args ]", "Execute something in the context of this wallet."
        define_method(coin.name.downcase.to_sym, &block)

        desc "#{ coin.symbol.to_s.downcase.to_sym } <action> [ <args ]", "Execute something in the context of this wallet."
        define_method(coin.symbol.to_s.downcase.to_sym, &block)
      end
    end

  end
end
