require 'hashie'
require 'oj'

module Coffer
  class Coin < Hashie::Trash

    property :name, :required => true, :from => 'name'
    property :home_page, :required => true, :from => 'home_page'
    property :symbol, :required => true, :from => 'symbol'
    property :executable, :required => true, :from => 'executable'
    property :config_file_path, :required => true, :from => 'config_file_path'
    property :config, :from => 'config'

    property :git_repo, :required => true, :from => 'git_repo'
    property :git_branch, :default => 'master', :from => 'git_branch'
    property :artifact_location, :default => 'src', :from => 'artifact_location'
    property :build_script, :default => 'cd src && make -f makefile.unix', :from => 'build_script'

    def self.new_from_json( json )
      new Hashie::Extensions::IndifferentAccess.inject!(Oj.load( json ))
    end

    def self.new_from_file( file )
      new_from_json File.open( file, 'r' ).read
    end
  end
end

