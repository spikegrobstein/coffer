require 'fileutils'
require 'set'

require 'coffer/configuration'

module Coffer
  class Definition

    attr_accessor :config

    def initialize
      validate!
    end

    def validate!
      raise "Git repo required!" if @@git_repo.nil?
      raise "wallet_executable required!" if @@wallet_executable.nil?
      raise "directory required!" if @@directory.nil?
    end

    def requirements
      @@requirements
    end

    def name
      self.class.name
    end

    class << self

      def name
        name = ActiveSupport::Inflector.demodulize(self)
        name = ActiveSupport::Inflector.underscore(name)
      end

      def config_field( key, value )
        @config_fields ||= []
        @config_fields << [key,value]
      end

      def build_config
        return @config if @config

        @config = Configuration.new

        @config.add :rpcuser, 'cofferuser'
        @config.add :rpcpassword, 'cofferpass'
        @config.add :server, '1'
        @config.add :rpcallowip, '127.0.0.1'
        @config.add :listen, '1'
        @config.add :port, '4444' #Coffer::Registry.port

        # now custom fields
        if @config_fields
          fields.each do |f|
            @config.add f[0], f[1]
          end
        end

        @config
      end

      def attr_field( name, default=nil )
        class_eval do
          instance_variable_set "@#{name}", default
          # class_variable_set "@#{name}", default

          define_singleton_method(name) do |v=nil|
            unless v.nil?
              instance_variable_set "@#{name}", v
            end

            instance_variable_get "@#{name}"
          end

          define_method(name) do
            self.class.instance_variable_get "@#{name}"
          end
        end

      end
    end

    attr_field :git_repo
    attr_field :wallet_executable
    attr_field :symbol
    attr_field :home_page
    attr_field :directory
    attr_field :config_file

  end

end
