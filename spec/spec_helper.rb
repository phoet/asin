$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')

require 'rspec'
require 'asin'
require 'pp'
require 'httpclient'
require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'cassettes'
  c.stub_with :webmock
  # c.default_cassette_options = { :record => :new_episodes }
end

ANY_ASIN            = '1430218150'
ANY_OTHER_ASIN      = '1430216263'
ANY_BROWSE_NODE_ID  = '599826'
MULTIPLE_ASINS      = %w(1430218150 0439023521)

RSpec.configure do |config|
  config.mock_with :rspec
  config.extend VCR::RSpec::Macros
end

# setup for travis-ci
ENV['ASIN_SECRET'] ||= 'any_secret'
ENV['ASIN_KEY']    ||= 'any_key'
