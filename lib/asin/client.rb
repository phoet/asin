# -*- coding: utf-8 -*-
require 'httpi'
require 'crack/xml'
require 'cgi'
require 'base64'

# ASIN (Amazon Simple INterface) is a gem for easy access of the Amazon E-Commerce-API.
# It is simple to configure and use. Since it's very small and flexible, it is easy to extend it to your needs.
#
# Author::    Peter Schröder  (mailto:phoetmail@googlemail.com)
#
# == Usage
#
# The ASIN module is designed as a mixin.
#
#   require 'asin'
#   include ASIN::Client
#
# In order to use the Amazon API properly, you need to be a registered user (http://aws.amazon.com).
#
# The registration process will give you a +secret-key+ and an +access-key+ (AWSAccessKeyId).
#
# Both are needed to use ASIN (see Configuration for more details):
#
#   configure :secret => 'your-secret', :key => 'your-key'
#
# == Search
#
# After configuring your environment you can call the +lookup+ method to retrieve an +SimpleItem+ via the
# Amazon Standard Identification Number (ASIN):
#
#   item = lookup '1430218150'
#   item.first.title
#   => "Learn Objective-C on the Mac (Learn Series)"
#
# OR search with fulltext/ASIN/ISBN
#
#   items = search 'Learn Objective-C'
#   items.first.title
#   => "Learn Objective-C on the Mac (Learn Series)"
#
# The +SimpleItem+ uses a Hashie::Mash as its internal data representation and you can get fetched data from it:
#
#   item.raw.ItemAttributes.ListPrice.FormattedPrice
#   => "$39.99"
#
# == Further Configuration
#
# If you need more controll over the request that is sent to the
# Amazon API (http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html),
# you can override some defaults or add additional query-parameters to the REST calls:
#
#   configure :host => 'webservices.amazon.de'
#   lookup(asin, :ResponseGroup => :Medium)
#
# == Cart
#
# ASIN helps with AWS cart-operations.
# It currently supports the CartCreate, CartGet, CartAdd, CartModify and CartClear operations:
#
#   cart = create_cart({:asin => '1430218150', :quantity => 1})
#   cart.valid?
#   cart.items
#   => true
#   => [<#Hashie::Mash ASIN="1430218150" CartItemId="U3G241HVLLB8N6" ... >]
#
#   cart = get_cart('176-9182855-2326919', 'KgeVCA0YJTbuN/7Ibakrk/KnHWA=')
#   cart.empty?
#   => false
#
#   cart = clear_cart(cart)
#   cart.empty?
#   => true
#
#   cart = add_items(cart, {:asin => '1430216263', :quantity => 2})
#   cart.empty?
#   => false
#
#   cart = update_items(cart, {:cart_item_id => cart.items.first.CartItemId, :action => :SaveForLater}, {:cart_item_id => cart.items.first.CartItemId, :quantity => 7})
#   cart.valid?
#   cart.saved_items
#   => true
#   => [<#Hashie::Mash ASIN="1430218150" CartItemId="U3G241HVLLB8N6" ... >]
#
# == Nodes
#
# In order to browse Amazon nodes, you can use +browse_node+ method:
#
#   node = browse_node('163357')
#   node.node_id
#   => '163357'
#   node.name
#   => 'Comedy'
#   node.children
#   node.ancestors
#
# you can configure the +:ResponseGroup+ option to your needs:
#
#   node = browse_node('163357', :ResponseGroup => :TopSellers)
#
module ASIN
  module Client

    DIGEST  = OpenSSL::Digest::Digest.new('sha256')
    PATH    = '/onca/xml'

    # Convenience method to create an ASIN client.
    #
    # An instance is not necessary though, you can simply include the ASIN module otherwise.
    #
    def self.instance
      ins = Object.new
      ins.extend ASIN::Client
      ins
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
    # Expects an arbitrary number of ASIN (Amazon Standard Identification Number) and returns an array of +SimpleItem+:
    #
    #   item = lookup '1430218150'
    #   item.title
    #   => "Learn Objective-C on the Mac (Learn Series)"
    #   items = lookup ['1430218150', '0439023521']
    #   items[0].title
    #   => "Learn Objective-C on the Mac (Learn Series)"
    #   items[1].title
    #   => "The Hunger Games"
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   lookup(asin, :ResponseGroup => :Medium)
    #
    # Or with multiple parameters:
    #
    #   lookup(asin, :ResponseGroup => [:Small, :AlternateVersions])
    #
    def lookup(*asins)
      params = asins.last.is_a?(Hash) ? asins.pop : {:ResponseGroup => :Medium}
      response = call(params.merge(:Operation => :ItemLookup, :ItemId => asins.join(',')))
      arrayfy(response['ItemLookupResponse']['Items']['Item']).map {|item| handle_item(item)}
    end

    # Performs an +ItemSearch+ REST call against the Amazon API.
    #
    # Expects a search-string which can be an arbitrary array of strings (ASINs f.e.) and returns a list of +SimpleItem+s:
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
    # Have a look at the different search index values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def search_keywords(*keywords)
      params = keywords.last.is_a?(Hash) ? keywords.pop : {:SearchIndex => :Books, :ResponseGroup => :Medium}
      response = call(params.merge(:Operation => :ItemSearch, :Keywords => keywords.join(' ')))
      arrayfy(response['ItemSearchResponse']['Items']['Item']).map {|item| handle_item(item)}
    end

    # Performs an +ItemSearch+ REST call against the Amazon API.
    #
    # Expects a Hash of search params where and returns a list of +SimpleItem+s:
    #
    #   items = search :SearchIndex => :Music
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   search(:Keywords => 'nirvana', :SearchIndex => :Music)
    #
    # Have a look at the different search index values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def search(params={:SearchIndex => :Books, :ResponseGroup => :Medium})
      response = call(params.merge(:Operation => :ItemSearch))
      arrayfy(response['ItemSearchResponse']['Items']['Item']).map {|item| handle_item(item)}
    end

    # Performs an +BrowseNodeLookup+ REST call against the Amazon API.
    #
    # Expects a Hash of search params where and returns a +SimpleNode+:
    #
    #   node = browse_node '163357'
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   browse_node('163357', :ResponseGroup => :TopSellers)
    #
    # Have a look at the different browse node values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def browse_node(node_id, params={:ResponseGroup => :BrowseNodeInfo})
      response = call(params.merge(:Operation => :BrowseNodeLookup, :BrowseNodeId => node_id))
      handle_type(response['BrowseNodeLookupResponse']['BrowseNodes']['BrowseNode'], Configuration.node_type)
    end

    # Performs an +CartCreate+ REST call against the Amazon API.
    #
    # Expects one ore more item-hashes and returns a +SimpleCart+:
    #
    #   cart = create_cart({:asin => '1430218150', :quantity => 1})
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   create_cart({:asin => '1430218150', :quantity => 1}, {:asin => '1430216263', :quantity => 1, :action => :SaveForLater})
    #
    # Have a look at the different cart item operation values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def create_cart(*items)
      cart(:CartCreate, create_item_params(items))
    end

    # Performs an +CartGet+ REST call against the Amazon API.
    #
    # Expects the CartId and the HMAC to identify the returning +SimpleCart+:
    #
    #   cart = get_cart('176-9182855-2326919', 'KgeVCA0YJTbuN/7Ibakrk/KnHWA=')
    #
    def get_cart(cart_id, hmac)
      cart(:CartGet, {:CartId => cart_id, :HMAC => hmac})
    end

    # Performs an +CartAdd+ REST call against the Amazon API.
    #
    # Expects a +SimpleCart+ created with +create_cart+ and one ore more Item-Hashes and returns an updated +SimpleCart+:
    #
    #   cart = add_items(cart, {:asin => '1430216263', :quantity => 2})
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   add_items(cart, {:asin => '1430218150', :quantity => 1}, {:asin => '1430216263', :quantity => 1, :action => :SaveForLater})
    #
    # Have a look at the different cart item operation values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def add_items(cart, *items)
      cart(:CartAdd, create_item_params(items).merge({:CartId => cart.cart_id, :HMAC => cart.hmac}))
    end

    # Performs an +CartModify+ REST call against the Amazon API.
    #
    # Expects a +SimpleCart+ created with +create_cart+ and one ore more Item-Hashes to modify and returns an updated +SimpleCart+:
    #
    #   cart = update_items(cart, {:cart_item_id => cart.items.first.CartItemId, :quantity => 7})
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   update_items(cart, {:cart_item_id => cart.items.first.CartItemId, :action => :SaveForLater}, {:cart_item_id => cart.items.first.CartItemId, :quantity => 7})
    #
    # Have a look at the different cart item operation values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def update_items(cart, *items)
      cart(:CartModify, create_item_params(items).merge({:CartId => cart.cart_id, :HMAC => cart.hmac}))
    end

    # Performs an +CartClear+ REST call against the Amazon API.
    #
    # Expects a +SimpleCart+ created with +create_cart+ and returns an empty +SimpleCart+:
    #
    #   cart = clear_cart(cart)
    #
    def clear_cart(cart)
      cart(:CartClear, {:CartId => cart.cart_id, :HMAC => cart.hmac})
    end

    private()
    
    def arrayfy(item)
      return [] unless item
      item.is_a?(Array) ? item : [item]
    end

    def handle_item(item)
      handle_type(item, Configuration.item_type)
    end

    def handle_type(data, type)
      if type.is_a?(Class)
        type.new(data)
      elsif type == :mash
        require 'hashie'
        Hashie::Mash.new(data)
      elsif type == :rash
        require 'rash'
        Hashie::Rash.new(data)
      else
        data
      end
    end

    def create_item_params(items)
      keyword_mappings = {
        :asin               => 'ASIN',
        :quantity           => 'Quantity',
        :cart_item_id       => 'CartItemId',
        :offer_listing_id   => 'OfferListingId',
        :action             => 'Action'
      }
      params = {}
      items.each_with_index do |item, i|
        item.each do |key, value|
          next unless keyword = keyword_mappings[key]
          params["Item.#{i}.#{keyword}"] = value.to_s
        end
      end
      params
    end

    def cart(operation, params={})
      response = call(params.merge(:Operation => operation))
      cart = response["#{operation}Response"]['Cart']
      handle_type(cart, Configuration.cart_type)
    end

    def call(params)
      Configuration.validate_credentials!

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

      params[:Version] = Configuration.version unless Configuration.blank? :version
      params[:AssociateTag] = Configuration.associate_tag unless Configuration.blank? :associate_tag

      # utc timestamp needed for signing
      params[:Timestamp] = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')

      
      query = create_query(params)

      # yeah, you really need to sign the get-request not the query
      request_to_sign = "GET\n#{Configuration.host}\n#{PATH}\n#{query}"
      hmac = OpenSSL::HMAC.digest(DIGEST, Configuration.secret, request_to_sign)

      # don't forget to remove the newline from base64
      signature = CGI.escape(Base64.encode64(hmac).chomp)
      "#{query}&Signature=#{signature}"
    end
    
    def create_query(params)
      params.map do |key, value|
        value = value.collect{|v| v.to_s.strip}.join(',') if value.is_a?(Array)
        "#{key}=#{CGI.escape(value.to_s)}"
      end.sort.join('&').gsub('+','%20') # signing needs to order the query alphabetically
    end

    def log(severity, message)
      Configuration.logger.send severity, message if Configuration.logger
    end
  end
end
