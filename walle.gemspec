# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'walle/version'

Gem::Specification.new do |spec|
  spec.name          = 'walle'
  spec.version       = Walle::VERSION
  spec.authors       = ['undr']
  spec.email         = ['undr@yandex.ru']

  spec.summary       = %q{Simple DSL for building Slack bots.}
  spec.description   = %q{Simple DSL for building Slack bots.}
  spec.homepage      = 'https://github.com/undr/walle'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'slack-ruby-client'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
