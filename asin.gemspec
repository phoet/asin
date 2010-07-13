# coding: utf-8

spec = Gem::Specification.new do |s|
  s.name = 'asin'
  s.version = '0.0.6'

  s.author = 'Peter Schröder'
  s.description = 'Amazon Simple INterface or whatever you want to call this.'
  s.email = 'phoetmail@googlemail.com'
  s.homepage = 'http://github.com/phoet/asin'
  s.summary = 'Simple interface to Amazon Item lookup.'

  s.has_rdoc = true
  s.rdoc_options = ['-a', '--inline-source', '--charset=UTF-8']
  s.extra_rdoc_files = ['readme.textile']
  s.files = Dir.glob('lib/*.rb')
  s.test_files = Dir.glob('test/test_*.rb')
  
  s.required_ruby_version = '>= 1.9'
  
  # trying not to be too restrictive...
  s.add_dependency('crack', '>= 0.1.0')
  s.add_dependency('hashie', '>= 0.2.0')
  s.add_dependency('httpclient', '>= 2.1.0')
end

