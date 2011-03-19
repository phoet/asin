$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')
require 'rspec'
require 'asin'
require 'pp'

ANY_ASIN = '1430218150'

Rspec.configure do |c|
  c.mock_with :rspec
end
