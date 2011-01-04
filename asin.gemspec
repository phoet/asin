# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "asin/version"

Gem::Specification.new do |s|
  s.name        = "asin"
  s.version     = Asin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Peter Schröder']
  s.email       = ['phoetmail@googlemail.com']
  s.homepage    = 'http://github.com/phoet/asin'
  s.summary     = 'Simple interface to Amazon Item lookup.'
  s.description = 'Amazon Simple INterface or whatever you want to call this.'

  s.rubyforge_project = "asin"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
