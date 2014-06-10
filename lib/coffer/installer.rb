require 'git'

module Coffer
  class Installer

    CACHE_DIR = '/opt/coffer/cache'
    BIN_DIR = '/opt/coffer/bin'

    attr_reader :coin

    def initialize( coin )
      @coin = coin
    end

    def install
      FileUtils.mkdir_p CACHE_DIR
      FileUtils.mkdir_p BIN_DIR

      update_repo
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

    # ensure that this git repo is running the latest
    # version and is cloned and all that
    def update_repo
      [ clone, pull ].count { |i| i } > 0
    end

    # clone a repo to the correct directory
    # if the directory already exists and is a git repo
    # then do nothing.
    def clone
      return false if File.directory?( repo_path )

      warn "Cloning repo... #{repo_path}"

      g = Git.clone( coin.git_repo, File.basename(repo_path), :path => File.dirname(repo_path) )

      true
    end

    # pull the latest changes and ensure we have the correct
    # ref checked out.
    def pull
      raise "Not a git repository! (#{ repo_path })" unless File.directory?( repo_path )

      warn "Updating repo... #{repo_path}"

      g = Git.open( repo_path, :logger => Logger.new(STDOUT) )

      # store the current SHA1
      old_sha = g.object('HEAD').sha

      # ensure the remote is configured as expected
      if g.remote.url != coin.git_repo
        g.remove_remote 'origin'
        g.add_remote 'origin', coin.git_repo, :fetch => true
      end

      # make sure the tree is clean
      g.reset_hard 'HEAD'
      g.clean :force => true, :d => true

      # fetch data from remote, checkout the right branch and merge into local branch
      g.pull

      # check if there are any changes.
      old_sha != g.object('HEAD').sha
    end

    def copy_built_executable
      FileUtils.cp built_executable_path, installed_executable_path
    end

    def create_directories
      FileUtils.mkdir wallet_home_directory, :mode => 0600
    end

    def wallet_home_directory
      File.expand_path("~/.#{ @coin.directory }")
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
      File.join CACHE_DIR, @coin.name
    end

    def installed_executable_path
      File.join BIN_DIR, @coin.wallet_executable
    end

    def built_executable_path
      File.join repo_path, 'src', @coin.wallet_executable
    end

    def built_executable_exists?
      File.exists? built_executable_path
    end

  end
end

