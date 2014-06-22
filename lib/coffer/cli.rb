require 'thor'
require 'coffer'
require 'pry'

module Coffer
  class CLI < Thor
    desc "list", "List all coins"
    def list
      running_wallets = Coffer::Wallet.running_wallets.map { |w| w['names'].scan(/(?:coffer\.)(.+)/).flatten.first }
      installed_wallets = Coffer::Wallet.installed_wallets

      Coffer::Registry.instance.coins.each do |coin|
        status = if running_wallets.include?(coin.name)
                   'running'
                 elsif installed_wallets.include?(coin.name)
                   'installed'
                 else
                   ''
                 end
        puts "%-20s %-6s %-20s" % [ coin.name, coin.symbol, status ]
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

      # build
      builder = Coffer::Builder.new(coin)
      builder.repo.update
      builder.build
      builder.install

      puts "Success!"
    end

    desc "build <coin>", "Build the given coin, but don't install"
    def build(coin)
      coin = Coffer::Registry.instance.find( coin )

      if coin.nil?
        warn "Unable to find a coin with a name or symbol of #{ coin }"
      end

      warn "installing coin: #{ coin.name } (#{coin.symbol})"

      # build
      builder = Coffer::Builder.new(coin)
      builder.repo.update
      builder.build
    end

    desc "clean <coin>", "Delete sourcecode and stuff."
    def clean(coin)
      coin = Coffer::Registry.instance.find( coin )

      if coin.nil?
        abort "Unable to find a coin with a name or symbol of #{ coin }"
      end

      builder = Coffer::Builder.new(coin)
      builder.repo.clean
    end

    desc "start <coin>", "Start the given coin."
    def start(coin)
      coin = Coffer::Registry.instance.find(coin)

      if coin.nil?
        warn "Unable to find a coin with a name or symbol of #{ coin }"
      end

      w = Coffer::Wallet.new(coin)
      w.start
    end

    desc "stop <coin>", "Stop the given coin."
    def stop(coin)
      coin = Coffer::Registry.instance.find(coin)

      raise "not implemented."
    end

    desc "rpc <coin> <action> [<params>]", "Run the given RPC against coin"
    def rpc(coin, action, *params)
      coin = Coffer::Registry.instance.find(coin)

      if coin.nil?
        abort "Unable to find a coin with a name or symbol of #{ coin }"
      end

      output = `docker ps | grep #{ coin.name }`
      host, port = output.scan(/\s(\d+\.\d+\.\d+\.\d+):(\d+)->4000/).first

      client = Client.new( host, port, 'cofferrpc', 'cofferrpcpassword')

      puts client.send(action, *params)

    end
  end
end
