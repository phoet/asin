$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')
require 'rspec'
require 'asin'

Rspec.configure do |c|
  c.mock_with :rspec
end
