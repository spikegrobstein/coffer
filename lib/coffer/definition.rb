require 'fileutils'
require 'set'

module Coffer
  class Definition

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
