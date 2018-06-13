$:.push File.expand_path("../lib", __FILE__)
require "asin/version"

Gem::Specification.new do |s|
  s.name        = "asin"
  s.version     = ASIN::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Peter Schröder']
  s.email       = ['phoetmail@googlemail.com']
  s.homepage    = 'http://github.com/phoet/asin'
  s.description = s.summary = 'Amazon Simple INterface - Support for ItemLookup, SimilarityLookup, Search, BrowseNode and Cart Operations.'

  s.rubyforge_project = "asin"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('crack',           '>= 0.3')
  s.add_dependency('hashie',          '>= 1.1')
  s.add_dependency('snake_case_hash', '>= 1.0.2')
  s.add_dependency('http',            '>= 3.0')
  s.add_dependency('confiture',       '>= 0.1')

  s.add_development_dependency('rake',                      '~> 0.9')
  s.add_development_dependency('vcr',                       '~> 4.0')
  s.add_development_dependency('webmock',                   '~> 3.4')
  s.add_development_dependency('rspec',                     '~> 2.11')
  s.add_development_dependency('rspec-collection_matchers', '~> 1.1')
end
