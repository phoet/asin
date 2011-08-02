# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "asin/version"

Gem::Specification.new do |s|
  s.name        = "asin"
  s.version     = ASIN::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Peter Schröder']
  s.email       = ['phoetmail@googlemail.com']
  s.homepage    = 'http://github.com/phoet/asin'
  s.summary     = 'Simple interface to AWS Lookup, Search and Cart operations.'
  s.description = 'Amazon Simple INterface.'

  s.rubyforge_project = "asin" # rubyforge, WTF?!

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('crack',  '~> 0.1.8')
  s.add_dependency('hashie', '~> 1.0.0')
  s.add_dependency('httpi',  '~> 0.9.5')

  s.add_development_dependency('httpclient', '~> 2.2.1')
  s.add_development_dependency('rash',       '~> 0.3.0')
  
  s.add_development_dependency('rake',       '~> 0.9.2')
  s.add_development_dependency('httpclient', '~> 2.2.1')
  s.add_development_dependency('vcr',        '~> 1.10.3')
  s.add_development_dependency('webmock',    '~> 1.6.4')
  s.add_development_dependency('rspec',      '~> 2.6.0')
  s.add_development_dependency('fuubar',     '~> 0.0.5')
end
