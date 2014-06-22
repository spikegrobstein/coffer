require 'git'
require 'term/ansicolor'
require 'fileutils'
require 'logger'

module Coffer
  class GitRepository
    include Term::ANSIColor
    attr_reader :coin

    def initialize( coin )
      @coin = coin
    end

    # ensure that this git repo is running the latest
    # version and is cloned and all that
    def update
      [ clone, pull ].count { |i| i } > 0
    end

    # clone a repo to the correct directory
    # if the directory already exists and is a git repo
    # then do nothing.
    def clone
      return false if File.directory?( path )

      warn yellow("Cloning repo... #{ path }")

      g = Git.clone( coin.git_repo, coin.name, :path => Coffer::CACHE_DIR, :logger => Logger.new(STDOUT) )
      g.checkout @coin.git_branch

      true
    end

    # pull the latest changes and ensure we have the correct
    # ref checked out.
    def pull
      raise "Not a git repository! (#{ path })" unless File.directory?( path )

      warn yellow("Updating repo... #{path}")

      g = Git.open( path, :logger => Logger.new(STDOUT) )

      # store the current SHA1
      old_sha = g.object('HEAD').sha

      # ensure the remote is configured as expected
      if g.remote.url != coin.git_repo
        g.remove_remote 'origin'
        g.add_remote 'origin', coin.git_repo, :fetch => true
      end

      # make sure the tree is clean
      g.reset_hard
      g.clean :force => true, :d => true

      # fetch data from remote, checkout the right branch and merge into local branch
      g.checkout @coin.git_branch
      g.pull('origin', @coin.git_branch)

      # check if there are any changes.
      old_sha != g.object('HEAD').sha
    end

    def clean
      FileUtils.rm_rf( path )
    end

    def path
      File.join( Coffer::CACHE_DIR, @coin.name )
    end

  end
end

