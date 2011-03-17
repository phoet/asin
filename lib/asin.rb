# -*- coding: utf-8 -*-
require 'httpi'
require 'crack/xml'
require 'cgi'
require 'base64'
require 'logger'

require 'asin/item'
require 'asin/version'
require 'asin/configuration'

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
# Both are needed to use ASIN (see Configuration for more details):
# 
#   configure :secret => 'your-secret', :key => 'your-key'
# 
# After configuring your environment you can call the +lookup+ method to retrieve an +Item+ via the 
# Amazon Standard Identification Number (ASIN):
# 
#   item = lookup '1430218150'
#   item.title
#   => "Learn Objective-C on the Mac (Learn Series)"
#
# OR search with fulltext/ASIN/ISBN
# 
#   items = search 'Learn Objective-C'
#   items.first.title
#   => "Learn Objective-C on the Mac (Learn Series)"
# 
# The +Item+ uses a Hashie::Mash as its internal data representation and you can get fetched data from it:
# 
#   item.raw.ItemAttributes.ListPrice.FormattedPrice
#   => "$39.99"
# 
# ==Further Configuration
# 
# If you need more controll over the request that is sent to the 
# Amazon API (http://docs.amazonwebservices.com/AWSEcommerceService/4-0/),
# you can override some defaults or add additional query-parameters to the REST calls:
# 
#   configure :host => 'webservices.amazon.de'
#   lookup(asin, :ResponseGroup => :Medium)
# 
module ASIN
  
  DIGEST  = OpenSSL::Digest::Digest.new('sha256')
  PATH    = '/onca/xml'

  # Convenience method to create an ASIN client.
  # 
  # A client is not necessary though, you can simply include the ASIN module otherwise.
  # 
  def self.client
    client = Object.new
    client.extend ASIN
    client
  end

  # Configures the basic request parameters for ASIN.
  # 
  # Expects at least +secret+ and +key+ for the API call:
  # 
  #   configure :secret => 'your-secret', :key => 'your-key'
  # 
  # See ASIN::Configuration for more infos.
  # 
  def configure(options={})
    Configuration.configure(options)
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
    response = call(params.merge(:Operation => :ItemLookup, :ItemId => asin))
    Item.new(response['ItemLookupResponse']['Items']['Item'])
  end
  
  # Performs an +ItemSearch+ REST call against the Amazon API.
  # 
  # Expects a search-string which can be an arbitrary array of strings (ASINs f.e.) and returns a list of +Items+:
  # 
  #   items = search_keywords 'Learn', 'Objective-C'
  #   items.first.title
  #   => "Learn Objective-C on the Mac (Learn Series)"
  # 
  # ==== Options:
  # 
  # Additional parameters for the API call like this:
  # 
  #   search_keywords('nirvana', 'never mind', :SearchIndex => :Music)
  #
  # Have a look at the different search index values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSEcommerceService/4-0/]
  #
  def search_keywords(*keywords)
    params = keywords.last.is_a?(Hash) ? keywords.pop : {:SearchIndex => :Books}
    response = call(params.merge(:Operation => :ItemSearch, :Keywords => keywords.join(' ')))
    (response['ItemSearchResponse']['Items']['Item'] || []).map {|item| Item.new(item)}
  end
  
  # Performs an +ItemSearch+ REST call against the Amazon API.
  # 
  # Expects a Hash of search params where and returns a list of +Items+:
  # 
  #   items = search :SearchIndex => :Music
  # 
  # ==== Options:
  # 
  # Additional parameters for the API call like this:
  # 
  #   search(:Keywords => 'nirvana', :SearchIndex => :Music)
  #
  # Have a look at the different search index values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSEcommerceService/4-0/]
  #
  def search(params={:SearchIndex => :Books})
    response = call(params.merge(:Operation => :ItemSearch))
    (response['ItemSearchResponse']['Items']['Item'] || []).map {|item| Item.new(item)}
  end

  def cart_create(params)
    response = call(create_cart_item_params(params).merge(:Operation => :CartCreate))
    response["CartCreateResponse"]["Cart"]
  end

  def cart_add(params)
    response = call(create_cart_item_params(params).merge(create_cart_params(params)).merge({:Operation => :CartAdd}))
    response["CartAddResponse"]["Cart"]
  end

  def cart_update(params)
    response = call(create_cart_item_params(params).merge(create_cart_params(params)).merge({:Operation => :CartModify}))
    response["CartModifyResponse"]["Cart"]
  end

  def cart_clear(params)
    response = call(create_cart_params(params).merge(:Operation => :CartClear))
    response["CartClearResponse"]["Cart"]
  end

  def cart_remove(params)
    response = call(create_cart_item_params(params).merge(create_cart_params(params)).merge({:Operation => :CartModify}))
    response["CartModifyResponse"]["Cart"]
  end
  
  # Takes an array of item => quantity pairs and returns a hash of usable parameters
  # 
  # [{:asin => "foo", :quantity => 2}, 
  #  {:offer_listing_id => "bar", :quantity => 3}
  #  {:cart_item_id => "baz", :quantity => 4}]
  # 
  # #=>
  # 
  # {
  #   "Item.1.ASIN" => "foo",
  #   "Item.1.Quantity" => 2,
  #   "Item.2.OfferListingId" => "bar",
  #   "Item.2.Quantity" => 3,
  #   "Item.3.CartItemId" => "baz",
  #   "Item.3.Quantity" => 3
  # }

  def create_cart_params(params)
    raise ":cart_id is a required parameter for remote cart operations" unless params[:cart_id]
    raise ":hmac is a required parameter for remote cart operations" unless params[:hmac]
    {
      :CartId => params[:cart_id],
      :HMAC => params[:hmac]
    }
  end

  def create_cart_item_params(params)
    raise "You must specify at least one item for remote cart operations" unless params[:items]
    
    item_identifiers = [:asin, :offer_listing_id, :cart_item_id]
    item_identifiers_override_map = {:asin => "ASIN"}

    items = params[:items]

    items.reject! do |item|
      !item.keys.any? {|key| item_identifiers.include? key}
    end

    items.map! do |item|
      item.each do |key,value|
        item[key.to_s.downcase.to_sym] = item.delete(key)
      end
    end

    params = {}
    items.each_with_index do |item_hash, index|
      item_identifiers.each do |identifier|
        param_key = item_identifiers_override_map[identifier] || 
          identifier.to_s.split('_').map!{|m| m.capitalize}.join # poor-mans String#camelize
        params["Item.#{index+1}.#{param_key}"] = item_hash[identifier] if item_hash.has_key?(identifier)
      end
      params["Item.#{index+1}.Quantity"] = item_hash[:quantity] || 1
    end
    params
  end

  private

  def credentials_valid?
    !Configuration.secret.nil? && !Configuration.key.nil?
  end

  def call(params)
    raise "you have to configure ASIN: 'configure :secret => 'your-secret', :key => 'your-key''" unless credentials_valid?
    
    log(:debug, "calling with params=#{params}")
    signed = create_signed_query_string(params)
    
    url = "http://#{Configuration.host}#{PATH}?#{signed}"
    log(:info, "performing rest call to url='#{url}'")
   
    response = HTTPI.get(url)
    if response.code == 200
      # force utf-8 chars, works only on 1.9 string
      resp = response.body
      resp = resp.force_encoding('UTF-8') if resp.respond_to? :force_encoding
      log(:debug, "got response='#{resp}'")
      Crack::XML.parse(resp)
    else
      log(:error, "got response='#{response.body}'")
      raise "request failed with response-code='#{response.code}'"
    end
  end

  def create_signed_query_string(params)
    # nice tutorial http://cloudcarpenters.com/blog/amazon_products_api_request_signing/
    params[:Service] = :AWSECommerceService
    params[:AWSAccessKeyId] = Configuration.key
    # utc timestamp needed for signing
    params[:Timestamp] = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ') 
  
    # signing needs to order the query alphabetically
    query = params.map{|key, value| "#{key}=#{CGI.escape(value.to_s)}" }.sort.join('&').gsub('+','%20')
  
    # yeah, you really need to sign the get-request not the query
    request_to_sign = "GET\n#{Configuration.host}\n#{PATH}\n#{query}"
    hmac = OpenSSL::HMAC.digest(DIGEST, Configuration.secret, request_to_sign)
  
    # don't forget to remove the newline from base64
    signature = CGI.escape(Base64.encode64(hmac).chomp)
    "#{query}&Signature=#{signature}"
  end
  
  def log(severity, message)
    Configuration.logger.send severity, message if Configuration.logger
  end

end

