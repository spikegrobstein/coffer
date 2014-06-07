require 'fileutils'
require 'set'

module Coffer
  class CoinInstaller

    CACHE_DIR = '/tmp/coffer/cache'

    def initialize
      FileUtils.mkdir_p CACHE_DIR
    end

    def build
      clone
      # preconfigure

      Dir.chdir( File.join( repo_path, 'src') ) do
        make

        raise "Build failed. No executable!" unless executable_exists?
      end

      # create_directories
      # start
    end

    def clone
      Dir.chdir(CACHE_DIR) do
        `git clone '#{ @@git_repo }' '#{ self.class.to_s.downcase }'`
      end

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

    def executable_path
      File.join repo_path, 'src', @@wallet_executable
    end

    def executable_exists?
      File.exists? executable_path
    end

    def requirements
      @@requirements
    end

    class << self

      def git_repo( new_git_repo )
        @@git_repo = new_git_repo
      end

      def wallet_executable( new_wallet_exec )
        @@wallet_executable = new_wallet_exec
      end

      def requires( new_requirement )
        @@requirements ||= Set.new
        @@requirements << new_requirement
      end

    end
  end
end
