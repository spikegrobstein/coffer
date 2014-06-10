module Coffer
  class Configuration

    attr_accessor :fields

    def initialize
      @fields = []
    end

    def add( key, value )
      @fields << [ key, value ]
    end

    def to_config
      @fields.map { |f| f.join('=') }.join("\n")
    end
  end

end
