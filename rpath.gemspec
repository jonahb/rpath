# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rpath/version'

Gem::Specification.new do |spec|
  spec.name                  = 'rpath'
  spec.version               = RPath::VERSION
  spec.authors               = ['Jonah Burke']
  spec.email                 = ['jonah@jonahb.com']
  spec.summary               = 'Query XML with just Ruby'
  spec.homepage              = 'http://github.com/jonahb/rpath'
  spec.license               = 'MIT'
  spec.required_ruby_version = '>= 1.9.3'
  spec.require_paths         = ['lib']
  spec.files                 = Dir['LICENSE.txt', 'README.md', '.yardopts', 'lib/**/*']

  spec.add_development_dependency 'nokogiri', '~> 1.6.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'oga', '~> 0.2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard', '~> 0.8.7'
end
