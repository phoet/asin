# coverage is supposed to be the first thing in the file!
if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

# WORKAROUND (ps) for http://travis-ci.org/#!/phoet/asin/jobs/1794039
require "net/http"
unless Net.const_defined? :HTTPSession
  puts "monkeypatching Net::HTTPSession"
  class Net::HTTPSession < Net::HTTP::HTTPSession; end
end

require 'rspec'
require 'rspec/collection_matchers'
require 'asin'
require 'asin/adapter'
require 'vcr'
require 'byebug'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.ignore_hosts 'codeclimate.com'
end

ANY_ASIN            = '1430218150'
ANY_OTHER_ASIN      = '1430216263'
ANY_BROWSE_NODE_ID  = '599826'

RSpec.configure do |config|
  config.mock_with :rspec

  # https://gist.github.com/1212530
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.around(:each, :vcr => true) do |example|
    name = example.metadata[:full_description].downcase.gsub(/\W+/, "_").split("_", 2).join("/")
    VCR.use_cassette(name, :record => :new_episodes, :match_requests_on => [:host, :path]) do
      example.call
    end
  end

  config.before :each do
    ASIN::Configuration.reset!
    @helper = ASIN::Client.instance
    @helper.configure :logger => nil

    @secret = ENV['ASIN_SECRET']
    @key    = ENV['ASIN_KEY']
    @tag    = ENV['ASIN_TAG']
  end
end

# setup for travis-ci
ENV['ASIN_SECRET'] ||= 'any_secret'
ENV['ASIN_KEY']    ||= 'any_key'
ENV['ASIN_TAG']    ||= 'any_tag'
