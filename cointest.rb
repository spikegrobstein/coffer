require 'rubygems'
require 'bundler/setup'
require 'git'
require 'ostruct'
require 'logger'
require 'term/ansicolor'
require 'oj'
require 'hashie'

require 'pry'

feathercoin_def = {
  :name              => 'feathercoin',
  :home_page         => 'https://www.feathercoin.com',
  :symbol            => :FTC,
  :executable        => 'feathercoind',
  :config_file_path       => '.feathercoin/feathercoin.conf',

  :git_repo          => 'https://github.com/FeatherCoin/Feathercoin.git',
  :git_branch        => 'master-0.8'
  # :artifact_location => 'src',

  # :build_script      => "cd src && make -f makefile.unix"
}

litecoin_def = {
  :name              => 'litecoin',
  :home_page         => 'https://www.litecoin.com',
  :symbol            => :LTC,
  :executable        => 'litecoind',
  :config_file_path       => '.litecoin/litecoin.conf',

  :git_repo          => 'https://github.com/litecoin-project/litecoin.git',
  # :git_branch        => 'master-0.8'
  # :artifact_location => 'src',

  # :build_script      => "cd src && make -f makefile.unix"
}

module Coffer
  HOME_DIR = File.expand_path('~/.coffer')
  CACHE_DIR = File.join(HOME_DIR, 'cache')
end

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

litecoin = Coffer::Coin.new(litecoin_def)
feathercoin = Coffer::Coin.new(feathercoin_def)

ltc_json_def = Oj.dump( litecoin_def, :mode => :compat )
ltc_coin = Coffer::Coin.new_from_json(ltc_json_def)
binding.pry

exit

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

class Builder
  include Term::ANSIColor

  attr_reader :coin, # coin-specific stuff
              :repo # GitRepository

  def initialize( coin )
    @coin = coin
    @repo = GitRepository.new(coin)

    create_directories
  end

  def create_directories
    FileUtils.mkdir_p Coffer::CACHE_DIR
  end

  # execute in docker container
  def docker_exec( cmd, mount )
    image_name = 'spikegrobstein/coffer'

    docker_cmd = [
      'docker run',
      '-t', # allocate TTY
      "-v '#{ mount }':/coffer", # mount
      "-w /coffer", # working directory
      image_name,
      cmd
    ].join(' ')

    warn yellow("Running: #{ docker_cmd }")

    puts `#{docker_cmd }`

    $?.success? or raise "Error when running command; status #{$?.exitstatus}"
  end

  def build
    # drop the build script
    build_script = <<EOF
#! /bin/bash -

#{ @coin.build_script }
EOF

    build_script_path = File.join(repo.path, 'coffer-build.sh')

    File.open( build_script_path, 'w') do |f|
      f.write build_script
    end

    FileUtils.chmod( 0755, build_script_path )

    # run it in the container
    docker_exec 'ls -l', repo.path
    docker_exec './coffer-build.sh', repo.path

    validate_executable or raise "No executable found!"
  end

  def artifact_path
    File.join(repo.path, @coin.artifact_location, @coin.executable)
  end

  def validate_executable
    File.exists?(artifact_path) && File.executable?(artifact_path)
  end

  def install
    wallet = Wallet.new( @coin )
    wallet.create( artifact_path )
  end
end

# wallet directory structure:
# ~/.coffer/wallets
#   bin/<wallet>
#   definition.json
#   <config_dir>

class Wallet
  include Term::ANSIColor

  attr_accessor :coin, :home_path

  def initialize( coin )
    @coin = coin
    @home_path = File.join( Coffer::HOME_DIR, 'wallets', @coin.name )
  end

  def bin_path
    File.join home_path, 'bin'
  end

  def definition_path
    File.join home_path, 'definition.json'
  end

  def wallet_data_path
    File.join home_path, File.dirname(@coin.config_file_path)
  end

  def executable_path
    File.join bin_path, @coin.executable
  end

  def config_path
    File.join home_path, @coin.config_file_path
  end

  # given an executable, drop it in the right place and stuff
  def create( new_executable )
    FileUtils.mkdir_p bin_path
    FileUtils.mkdir_p wallet_data_path

    FileUtils.cp new_executable, executable_path

    # drop the definition
    File.open( definition_path, 'w' ) do |f|
      f.write Oj.dump(@coin.marshal_dump, :mode => :compat)
    end

    # dump config
    File.open( config_path, 'w' ) do |f|
      f.write <<EOF
rpcuser=cofferrpc
rpcpassword=cofferrpcpassword
server=1
rpcallowip=*
rpcport=4000
listen=1
EOF
    end

    FileUtils.chmod 0600, config_path
  end

  # execute in docker container
  def docker_exec( cmd, mount )
    image_name = 'spikegrobstein/coffer'

    docker_cmd = [
      'docker run',
      '-t', # allocate TTY
      "-v '#{ mount }':/coffer", # mount
      "-w /coffer", # working directory
      '-e HOME=/coffer',
      '-d',
      "--name coffer.#{@coin.name}",
      '-p 172.17.42.1::4000',
      image_name,
      cmd
    ].join(' ')

    warn yellow("Running: #{ docker_cmd }")

    puts `#{docker_cmd }`

    $?.success? or raise "Error when running command; status #{$?.exitstatus}"
  end

  def start
    docker_exec File.join('bin', @coin.executable), home_path
  end
end

class Client
  attr_accessor :port, :host, :username, :password

  def initialize( host, port , username, password )
    @port = port
    @host = host
    @username = username
    @password = password
  end

  def method_missing(name, *args)
    post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    resp['result']
  end

  def http_post_request(post_body)
    http    = Net::HTTP.new(host, port)
    request = Net::HTTP::Post.new('/')
    request.basic_auth username, password
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  end

  class JSONRPCError < RuntimeError; end
end

b = Builder.new( feathercoin )
# b.repo.clean
b.repo.update
b.build

b.install

puts Term::ANSIColor.green("Success!")

w = Wallet.new( feathercoin )
w.start

output = `docker ps | grep #{ feathercoin.name }`
host, port = output.scan(/\s(\d+\.\d+\.\d+\.\d+):(\d+)->4000/).first

binding.pry
client = Client.new( host, port, 'cofferrpc', 'cofferrpcpassword')

puts client.getinfo

binding.pry
