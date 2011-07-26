$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')

require 'rspec'
require 'asin'
require 'pp'

ANY_ASIN            = '1430218150'
ANY_OTHER_ASIN      = '1430216263'
ANY_BROWSE_NODE_ID  = '599826'

RSpec.configure do |c|
  c.mock_with :rspec
end
