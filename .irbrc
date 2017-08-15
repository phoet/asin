$:.unshift File.expand_path('lib')

require 'asin'

ASIN::Configuration.configure do |config|
  config.secret        = ENV['ASIN_SECRET']
  config.key           = ENV['ASIN_KEY']
  config.associate_tag = ENV['ASIN_TAG']
  config.host          = 'webservices.amazon.de'
end

@client = ASIN::Client.instance
