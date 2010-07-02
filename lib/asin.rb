require 'hashie'
require 'httpclient'
require 'crack/xml'
require 'cgi'
require 'base64'

module ASIN

  class Item

    attr_reader :raw

    def initialize(hash)
      @raw = Hashie::Mash.new(hash).ItemLookupResponse.Items.Item
    end

    def title
      @raw.ItemAttributes.Title
    end

  end

  def configure(options={})
    @options = {
      :host => 'webservices.amazon.com', 
      :path => '/onca/xml', 
      :digest => OpenSSL::Digest::Digest.new('sha256'),
      :key => '', 
      :secret => '',
    }
    @options.merge! options
  end

  def lookup(asin, params={})
    Item.new(call(params.merge(:Operation => :ItemLookup, :ItemId => asin)))
  end

  def call(params)
    configure if @options.nil?
    signed = doasign(params)
    resp = HTTPClient.new.get_content("http://#{@options[:host]}#{@options[:path]}?#{signed}")
    resp = resp.force_encoding('UTF-8') # shady workaround cause amazon returns bad utf-8 chars
    Crack::XML.parse(resp)
  end

  def doasign(params) # http://cloudcarpenters.com/blog/amazon_products_api_request_signing/
    params[:Service] = :AWSECommerceService
    params[:AWSAccessKeyId] = @options[:key]
    params[:Timestamp] = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ') # needed for signing
    
    query = params.map{|key, value| "#{key}=#{CGI.escape(value.to_s)}" }.sort.join('&')
    
    request_to_sign = "GET\n#{@options[:host]}\n#{@options[:path]}\n#{query}"
    hmac = OpenSSL::HMAC.digest(@options[:digest], @options[:secret], request_to_sign)
    
    signature = CGI.escape(Base64.encode64(hmac).chomp)
    "#{query}&Signature=#{signature}"
  end

end