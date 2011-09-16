$:.unshift File.join(File.dirname(__FILE__),'..','..','lib')

require 'rspec'
require 'asin'
require 'asin/client' # is somehow needed for jruby
require 'pp'
require 'httpclient'
require 'vcr'
require 'httpi'

VCR.config do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.stub_with :webmock
  # c.default_cassette_options = { :record => :new_episodes }
end

ANY_ASIN            = '1430218150'
ANY_OTHER_ASIN      = '1430216263'
ANY_BROWSE_NODE_ID  = '599826'

RSpec.configure do |config|
  config.mock_with :rspec
  config.extend VCR::RSpec::Macros
  
  config.before :each do
    HTTPI.log = false
    
    ASIN::Configuration.reset
    @helper = ASIN::Client.instance
    @helper.configure :logger => nil

    @secret = ENV['ASIN_SECRET']
    @key = ENV['ASIN_KEY']
  end
end

# setup for travis-ci
ENV['ASIN_SECRET'] ||= 'any_secret'
ENV['ASIN_KEY']    ||= 'any_key'
