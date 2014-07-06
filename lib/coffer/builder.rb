require 'term/ansicolor'
require 'coffer/git_repository'

module Coffer
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
      warn "creating wallet #{ @coin.name }"
      wallet.create( artifact_path )
    end
  end
end
