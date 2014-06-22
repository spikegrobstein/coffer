require 'term/ansicolor'
require 'fileutils'
require 'oj'

module Coffer
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
end
