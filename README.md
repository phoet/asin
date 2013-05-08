## Infos

[![Build Status](https://secure.travis-ci.org/phoet/asin.png)](http://travis-ci.org/phoet/asin)

ASIN is a simple, extensible wrapper for parts of the REST-API of Amazon Product Advertising API (aka Associates Web Service aka Amazon E-Commerce Service).

For more information on the REST calls, have a look at the whole [Amazon E-Commerce-API](http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html).

Have a look at the [RDOC](http://rdoc.info/projects/phoet/asin) for this project, if you like browsing some docs.

The gem runs smoothly with Rails 3 and is tested against multiple rubies. See *.travis.yml* for details.

## Installation

    gem install asin
    gem install httpclient # optional, see HTTPI

or in your Gemfile:

    gem 'asin'
    gem 'httpclient' # optional, see HTTPI

## Configuration

Rails style initializer (config/initializers/asin.rb):

    ASIN::Configuration.configure do |config|
      config.secret        = 'your-secret'
      config.key           = 'your-key'
      config.associate_tag = 'your-tag'
    end

Have a look at ASIN::Configuration class for all the details.

## Usage

ASIN is designed as a module, so you can include it into any object you like:

    # require and include
    require 'asin'
    include ASIN::Client
    
    # lookup an ASIN
    lookup '1430218150'

    # lookup multiple items by ASIN
    lookup ['1430218150','1934356549']

But you can also use the *instance* method to get a proxy-object:

    # just require
    require 'asin'
    
    # create an ASIN client
    client = ASIN::Client.instance
    
    # lookup an item with the amazon standard identification number (asin)
    items = client.lookup '1430218150'
    
    # have a look at the title of the item
    items.first.title
    => Learn Objective-C on the Mac (Learn Series)
    
    # search for any kind of stuff on amazon with keywords
    items = search_keywords 'Learn', 'Objective-C'
    items.first.title
    => "Learn Objective-C on the Mac (Learn Series)"
    
    # search for any kind of stuff on amazon with custom parameters
    search :Keywords => 'Learn Objective-C', :SearchIndex => :Books
    items.first.title
    => "Learn Objective-C on the Mac (Learn Series)"
    
    # access the internal data representation (Hashie::Mash)
    item.raw.ItemAttributes.ListPrice.FormattedPrice
    => $39.99
    
    # search for similar items like the one you already have
    items = client.similar '1430218150'

There is an additional set of methods to support AWS cart operations:

    client = ASIN::Client.instance
    
    # create a cart with an item
    cart = client.create_cart({:asin => '1430218150', :quantity => 1})
    cart.items
    => [<#Hashie::Mash ASIN="1430218150" CartItemId="U3G241HVLLB8N6" ... >]
    
    # get an already existing cart from a CartId and HMAC
    cart = client.get_cart('176-9182855-2326919', 'KgeVCA0YJTbuN/7Ibakrk/KnHWA=')
    cart.empty?
    => false
    
    # clear everything from the cart
    cart = client.clear_cart(cart)
    cart.empty?
    => true
    
    # add items to the cart
    cart = client.add_items(cart, {:asin => '1430216263', :quantity => 2})
    cart.empty?
    => false
    
    # update items in the cart
    cart = client.update_items(cart, {:cart_item_id => cart.items.first.CartItemId, :action => :SaveForLater}, {:cart_item_id => cart.items.first.CartItemId, :quantity => 7})
    cart.saved_items
    => [<#Hashie::Mash ASIN="1430218150" CartItemId="U3G241HVLLB8N6" ... >]

It's also possible to access browse nodes:

    client = ASIN::Client.instance
    
    # create a cart with an item
    node = client.browse_node('163357', :ResponseGroup => :TopSellers)
    node.node_id
    => '163357'
    node.name
    => 'Comedy'

## Response Configuration

ASIN is customizable in the way it returns Responses from Amazon.
By default it will return *SimpleItem*, *SimpleCart* or *SimpleNode* instances,
but you can override this behavior for using your custom Classes:

    client.configure :item_type => YourItemClass
    client.configure :cart_type => YourCartClass
    client.configure :node_type => YourNodeClass

You can also use built-in *:raw*, *:mash* types.
## HTTPI

ASIN uses [HTTPI](https://github.com/rubiii/httpi) as a HTTP-Client adapter.
See the HTTPI documentation for how to configure different clients or the logger.
As a default HTTPI uses _httpclient_ so you should add that dependency to your project:

    gem 'httpclient'

## Confiture

ASIN uses [Confiture](https://github.com/phoet/confiture) as a Configuration gem.
See the Confiture documentation for different configuration styles.

## License

"THE BEER-WARE LICENSE" (Revision 42):
[ps@nofail.de](mailto:ps@nofail.de) wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return Peter Schröder
