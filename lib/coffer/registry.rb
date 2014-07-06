require 'fileutils'
require 'active_support' # FIXME: this takes about half a second to load
require 'singleton'

module Coffer
  class Registry
    include Singleton

    attr_reader :coins

    def initialize
      @coins = []
      load_coins File.join(File.dirname(__FILE__), '../../coins')
    end

    def load_coins(directory)
      Dir["#{ directory }/*.json"].each do |d|
        begin
          self.load d
        rescue
          # report the failure, but continue.
          warn "Error loading coin definition: #{ d }"
        end
      end
    end

    def self.load(coin)
      instance.load coin
    end

    def load( coin )
      if coin.is_a?(Coffer::Coin)
        # do nothing
      elsif coin.is_a?(String)
        coin = Coffer::Coin.new_from_file(coin)
      elsif coin.is_a?(Hash)
        coin = Coffer::Coin.new(coin)
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
