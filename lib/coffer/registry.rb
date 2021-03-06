require 'fileutils'
require 'active_support' # FIXME: this takes about half a second to load
require 'singleton'

module Coffer
  class Registry
    include Singleton

    BASE_DIR = File.expand_path('~/.coffer')
    BIN_DIR = File.join(BASE_DIR, 'bin')
    DATA_FILE = File.join(BASE_DIR, 'coins.dat')

    attr_reader :coins

    def initialize
      make_directories
      @coins = []
      load_coins File.join(File.dirname(__FILE__), '../../coins')
    end

    def make_directories
      FileUtils.mkdir_p BIN_DIR
    end

    def load_coins(directory)
      Dir["#{ directory }/*.rb"].each do |d|
        require d

        self.load File.basename(d, '.rb')
      end
    end

    def self.load(coin)
      instance.load coin
    end

    def load( coin )
      if coin.is_a?(Symbol) || coin.is_a?(String)
        coin = ActiveSupport::Inflector.camelize( coin, true )
        coin = Coffer::Coin.const_get( coin )
      elsif coin.is_a?(Coffer::Definition)
        # pass
      else
        raise "Wrong type! (#{ coin.class.to_s })"
      end

      @coins << coin

      # warn "Loaded coin: #{ coin.inspect } #{ coin.symbol }"
    end

    def find( coin )
      coin = coin.downcase
      @coins.find do |c|
        c.name.downcase == coin || c.symbol.to_s.downcase == coin
      end
    end

  end
end
