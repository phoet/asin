$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')

require 'rspec'
require 'asin'
require 'pp'
require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :webmock
  c.default_cassette_options = { :record => :new_episodes }
end

ANY_ASIN            = '1430218150'
ANY_OTHER_ASIN      = '1430216263'
ANY_BROWSE_NODE_ID  = '599826'

RSpec.configure do |config|
  config.mock_with :rspec
  config.extend VCR::RSpec::Macros
end

