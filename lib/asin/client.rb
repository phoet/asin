require 'http'
require 'rexml/document' # https://github.com/phoet/asin/pull/23
require 'crack/xml'
require 'cgi'
require 'base64'

module ASIN
  module Client

    DIGEST  = OpenSSL::Digest.new('sha256')
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
    # Expects at least +secret+, +key+ and +associate_tag+ for the API call:
    #
    #   configure :secret => 'your-secret', :key => 'your-key', :associate_tag => 'your-associate_tag'
    #
    # See ASIN::Configuration for more infos.
    #
    def configure(options={})
      Configuration.configure(options)
    end

    # Performs an +ItemLookup+ REST call against the Amazon API.
    #
    # Expects an arbitrary number of ASIN (Amazon Standard Identification Number) and returns an array of item:
    #
    #   item = lookup '1430218150'
    #   items = lookup ['1430218150', '0439023521']
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
      arrayfy(response['ItemLookupResponse']['Items']['Item']).map {|item| handle_type(item, :item)}
    end

    # Performs an +ItemSearch+ REST call against the Amazon API.
    #
    # Expects a search-string which can be an arbitrary array of strings (ASINs f.e.) and returns a list of items:
    #
    #   items = search_keywords 'Learn', 'Objective-C'
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
      arrayfy(response['ItemSearchResponse']['Items']['Item']).map {|item| handle_type(item, :item)}
    end

    # Performs an +ItemSearch+ REST call against the Amazon API.
    #
    # Expects a Hash of search params and returns a list of items:
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
      arrayfy(response['ItemSearchResponse']['Items']['Item']).map {|item| handle_type(item, :item)}
    end

    # Performs an +BrowseNodeLookup+ REST call against the Amazon API.
    #
    # Expects a node-id and returns a node:
    #
    #   node = browse_node '17'
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   browse_node('17', :ResponseGroup => :TopSellers)
    #
    # Have a look at the different browse node values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html]
    #
    def browse_node(node_id, params={:ResponseGroup => :BrowseNodeInfo})
      response = call(params.merge(:Operation => :BrowseNodeLookup, :BrowseNodeId => node_id))
      arrayfy(response['BrowseNodeLookupResponse']['BrowseNodes']['BrowseNode']).map {|item| handle_type(item, :node)}
    end

    # Performs an +SimilarityLookup+ REST call against the Amazon API.
    #
    # Expects one ore more asins and returns a list of nodes:
    #
    #   items = similar '1430218150'
    #
    # ==== Options:
    #
    # Additional parameters for the API call like this:
    #
    #   similar('1430218150', :SimilarityType => :Intersection, :ResponseGroup => :Small)
    #
    # Have a look at the optional config values on the Amazon-Documentation[http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/SimilarityLookup.html]
    #
    def similar(*asins)
      params = asins.last.is_a?(Hash) ? asins.pop : {:SimilarityType => :Random, :ResponseGroup => :Medium}
      response = call(params.merge(:Operation => :SimilarityLookup, :ItemId => asins.join(',')))
      arrayfy(response['SimilarityLookupResponse']['Items']['Item']).map {|item| handle_type(item, :item)}
    end

    # Performs an +CartCreate+ REST call against the Amazon API.
    #
    # Expects one ore more item-hashes and returns a cart:
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
    # Expects the CartId and the HMAC to identify the returning cart:
    #
    #   cart = get_cart('176-9182855-2326919', 'KgeVCA0YJTbuN/7Ibakrk/KnHWA=')
    #
    def get_cart(cart_id, hmac)
      cart(:CartGet, {:CartId => cart_id, :HMAC => hmac})
    end

    # Performs an +CartAdd+ REST call against the Amazon API.
    #
    # Expects a cart created with +create_cart+ and one ore more Item-Hashes and returns an updated cart:
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
    # Expects a cart created with +create_cart+ and one ore more Item-Hashes to modify and returns an updated cart:
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
    # Expects a cart created with +create_cart+ and returns an empty cart:
    #
    #   cart = clear_cart(cart)
    #
    def clear_cart(cart)
      cart(:CartClear, {:CartId => cart.cart_id, :HMAC => cart.hmac})
    end

    private

    def arrayfy(item)
      return [] unless item
      item.is_a?(Array) ? item : [item]
    end

    def handle_type(data, type)
      Response.create(data)
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
      handle_type(cart, :cart)
    end

    def call(params)
      Configuration.validate!

      log(:debug, "calling with params=#{params}")
      signed = create_signed_query_string(params)

      url = "http://#{Configuration.host}#{PATH}?#{signed}"
      log(:info, "performing rest call to url='#{url}'")

      response = HTTP.get(url)
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
      params[:AssociateTag] = Configuration.associate_tag

      params[:Version] = Configuration.version unless Configuration.blank? :version

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
