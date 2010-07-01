require "rexml/rexml"
require 'hashie'
require 'httparty'

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
      :ResponseGroup => :Medium,
      :XMLEscaping => :Double,
      :Service => :AWSECommerceService,
    }
    @options = @options.merge options
  end
  
  def lookup(asin, options={})
    Item.new call(:Operation => :ItemLookup, :ItemId => asin)
  end
  
  BASE_URL = 'http://free.apisigning.com/onca/xml?'
  
  def call(params={})
    configure if @options.nil?
    params.merge! @options
    url = BASE_URL + params.map{|key, value| "#{key}=#{value}" }.join('&')
    HTTParty.get(url, :format => :xml, :timeout=>10).to_hash
  end

end