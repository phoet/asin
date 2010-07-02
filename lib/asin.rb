require 'hashie'
require 'httpclient'
require 'crack/xml'
require 'cgi'

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
    # some defaults that make sense
    @options = {
      :Service => :AWSECommerceService,
      :XMLEscaping => :Double, # => :Single, :Double
      :ContentType => 'text/plain;charset="UTF-8"', # trying to force utf-8
      :ResponseGroup => :Small, # => :Small, :Medium, :Large
    }
    @options = @options.merge options
  end
  
  def lookup(asin, params={})
    Item.new call(params.merge(:Operation => :ItemLookup, :ItemId => asin))
  end
  
  BASE_URL = 'http://free.apisigning.com/onca/xml?'
  
  def call(params={})
    configure if @options.nil?
    p url = BASE_URL + @options.merge(params).map{|key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join('&')
    resp = HTTPClient.new.get_content(url)
    p resp = resp.force_encoding('UTF-8') # shady workaround cause amazon returns bad utf-8 chars
    resp = Crack::XML.parse(resp)
    resp
  end

end