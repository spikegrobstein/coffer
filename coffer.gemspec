# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coffer/version'

Gem::Specification.new do |spec|
  spec.name          = "coffer"
  spec.version       = Coffer::VERSION
  spec.authors       = ["Spike Grobstein"]
  spec.email         = ["me@spike.cx"]
  spec.description   = %q{Cryptocurrency wallet manager}
  spec.summary       = %q{Cryptocurrency wallet manager -- like homebrew, but for your wallets. Linux-only right now.}
  spec.homepage      = "https://github.com/spikegrobstein/coffer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  spec.add_dependency 'activesupport'
  spec.add_dependency 'git'
  spec.add_dependency 'thor'
  spec.add_dependency 'term-ansicolor'
  spec.add_dependency 'oj'
end
