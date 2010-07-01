require 'hashie'
require 'httpclient'
require 'crack/xml'
require 'cgi'

module ASIN
  
  class Item
    def initialize(hash)
      @h = Hashie::Mash.new(hash)
    end
    
    def title
      @h.ItemLookupResponse.Items.Item.ItemAttributes.Title
    end
    
  end

  def configure(options={})
    @options = {
      :ResponseGroup => :Small,
      :Service => :AWSECommerceService,
      :XMLEscaping => :Double,
      :ContentType => 'text/plain;charset="UTF-8"'
    }
    @options = @options.merge options
  end
  
  def lookup(asin, params={})
    Item.new call(params.merge(:Operation => :ItemLookup, :ItemId => asin))
  end
  
  BASE_URL = 'http://free.apisigning.com/onca/xml?'
  
  def call(params={})
    configure if @options.nil?
    url = BASE_URL + params.merge(@options).map{|key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join('&')
    resp = HTTPClient.new.get_content(url)
    resp = resp.force_encoding('utf-8') # shady workaround cause amazon returns bad utf-8 chars
    resp = Crack::XML.parse(resp)
    resp
  end

end