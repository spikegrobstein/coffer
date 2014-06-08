require 'fileutils'
require 'set'

module Coffer
  module Installer

    CACHE_DIR = '/tmp/coffer/cache'
    BIN_DIR = '/tmp/coffer/bin'

    def build
      FileUtils.mkdir_p CACHE_DIR
      FileUtils.mkdir_p BIN_DIR

      clone
      # preconfigure

      Dir.chdir( File.join( repo_path, 'src') ) do
        FileUtils.mkdir 'obj' unless File.exists?('obj')
        make

        check_results
      end

      copy_built_executable
      create_directories
      create_config
      start
    end

    def clone
      Dir.chdir(CACHE_DIR) do
        `git clone '#{ git_repo }' '#{ self.class.to_s.downcase }'`
      end
    end

    def copy_built_executable
      FileUtils.cp built_executable_path, installed_executable_path
    end

    def create_directories
      FileUtils.mkdir wallet_home_directory, :mode => 0600
    end

    def wallet_home_directory
      File.expand_path("~/.#{ directory }")
    end

    def create_config
      File.open( File.join( wallet_home_path, config_file ), 'w' ) do |f|
        "config file"
      end
    end

    def start
      `#{ installed_executable_path } -daemon`
    end

    def check_results
      raise "Build failed. No executable!" unless built_executable_exists?
    end

    def make
      puts `make -f '#{ makefile_name }'`
    end

    def makefile_name
      sys = `uname`.chomp.downcase

      if sys == 'darwin'
        'makefile.osx'
      elsif sys == 'linux'
        'makefile.unix'
      end
    end

    def repo_path
      File.join CACHE_DIR, self.class.to_s.downcase
    end

    def installed_executable_path
      File.join BIN_PATH, wallet_executable
    end

    def built_executable_path
      File.join repo_path, 'src', wallet_executable
    end

    def built_executable_exists?
      File.exists? built_executable_path
    end

  end

  class Definition

    include Coffer::Installer

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

    class << self

      def attr_field( name, default=nil )
        class_eval do
          class_variable_set "@@#{name}", default

          define_singleton_method(name) do |v|
            class_variable_set "@@#{name}", v
          end

          define_method(name) do
            self.class.class_variable_get "@@#{name}"
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
