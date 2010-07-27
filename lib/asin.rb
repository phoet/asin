require 'hashie'
require 'httpclient'
require 'crack/xml'
require 'cgi'
require 'base64'
require 'logger'

# ASIN (Amazon Simple INterface) is a gem for easy access of the Amazon E-Commerce-API.
# It is simple to configure and use. Since it's very small and flexible, it is easy to extend it to your needs.
# 
# Author::    Peter Schröder  (mailto:phoetmail@googlemail.com)
# 
# ==Usage
# 
# The ASIN module is designed as a mixin.
# 
#   require 'asin'
#   include ASIN
# 
# In order to use the Amazon API properly, you need to be a registered user (http://aws.amazon.com).
# 
# The registration process will give you a +secret-key+ and an +access-key+ (AWSAccessKeyId).
# 
# Both are needed to use ASIN:
# 
#   configure :secret => 'your-secret', :key => 'your-key'
# 
# After configuring your environment you can call the +lookup+ method to retrieve an +Item+ via the Amazon Standard Identification Number (ASIN):
# 
#   item = lookup '1430218150'
#   item.title
#   => "Learn Objective-C on the Mac (Learn Series)"
# 
# The +Item+ uses a Hashie::Mash as its internal data representation and you can get fetched data from it:
# 
#   item.raw.ItemAttributes.ListPrice.FormattedPrice
#   => "$39.99"
# 
# ==Further Configuration
# 
# If you need more controll over the request that is sent to the Amazon API (http://docs.amazonwebservices.com/AWSEcommerceService/4-0/),
# you can override some defaults or add additional query-parameters to the REST calls:
# 
#   configure :host => 'webservices.amazon.de'
#   lookup(asin, :ResponseGroup => :Medium)
# 
module ASIN

  # =Item
  # 
  # The +Item+ class is a wrapper for the Amazon XML-REST-Response.
  # 
  # A Hashie::Mash is used for the internal data representation and can be accessed over the +raw+ attribute.
  # 
  class Item

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash).ItemLookupResponse.Items.Item
    end

    def title
      @raw.ItemAttributes.Title
    end

  end

  # Configures the basic request parameters for ASIN.
  # 
  # Expects at least +secret+ and +key+ for the API call:
  # 
  #   configure :secret => 'your-secret', :key => 'your-key'
  # 
  # ==== Options:
  # 
  # [secret] the API secret key
  # [key] the API access key
  # [host] the host, which defaults to 'webservices.amazon.com'
  # [logger] a different logger than logging to STDERR
  # 
  def configure(options={})
    @options = {
      :host => 'webservices.amazon.com', 
      :path => '/onca/xml', 
      :digest => OpenSSL::Digest::Digest.new('sha256'),
      :logger => Logger.new(STDERR),
      :key => '', 
      :secret => '',
    } if @options.nil?
    @options.merge! options
  end

  # Performs an +ItemLookup+ REST call against the Amazon API.
  # 
  # Expects an ASIN (Amazon Standard Identification Number) and returns an +Item+:
  # 
  #   item = lookup '1430218150'
  #   item.title
  #   => "Learn Objective-C on the Mac (Learn Series)"
  # 
  # ==== Options:
  # 
  # Additional parameters for the API call like this:
  # 
  #   lookup(asin, :ResponseGroup => :Medium)
  # 
  def lookup(asin, params={})
    Item.new(call(params.merge(:Operation => :ItemLookup, :ItemId => asin)))
  end

  private

  def call(params)
    raise "you have to configure ASIN: 'configure :secret => 'your-secret', :key => 'your-key''" if @options.nil?
    log(:debug, "calling with params=#{params}")
    signed = create_signed_query_string(params)
    url = "http://#{@options[:host]}#{@options[:path]}?#{signed}"
    log(:info, "performing rest call to url='#{url}'")
    resp = HTTPClient.new.get_content(url)
    # force utf-8 chars, works only on 1.9 string
    resp = resp.force_encoding('UTF-8') if resp.respond_to? :force_encoding
    log(:debug, "got response='#{resp}'")
    Crack::XML.parse(resp)
  end

  def create_signed_query_string(params)
    # nice tutorial http://cloudcarpenters.com/blog/amazon_products_api_request_signing/
    params[:Service] = :AWSECommerceService
    params[:AWSAccessKeyId] = @options[:key]
    # utc timestamp needed for signing
    params[:Timestamp] = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ') 
    
    query = params.map{|key, value| "#{key}=#{CGI.escape(value.to_s)}" }.sort.join('&')
    
    request_to_sign = "GET\n#{@options[:host]}\n#{@options[:path]}\n#{query}"
    hmac = OpenSSL::HMAC.digest(@options[:digest], @options[:secret], request_to_sign)
    
    signature = CGI.escape(Base64.encode64(hmac).chomp)
    "#{query}&Signature=#{signature}"
  end
  
  def log(severity, message)
    @options[:logger].send severity, message
  end

end