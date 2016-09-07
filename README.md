## Infos

[![Build Status](https://img.shields.io/travis/phoet/asin/master.svg)](https://travis-ci.org/phoet/asin)
[![Code Climate](https://img.shields.io/codeclimate/github/phoet/asin.svg)](https://codeclimate.com/github/phoet/asin)
[![Coverage Status](http://img.shields.io/codeclimate/coverage/github/phoet/asin.svg)](https://codeclimate.com/github/phoet/asin)


ASIN is a simple, extensible wrapper for parts of the REST-API of Amazon Product Advertising API (aka Associates Web Service aka Amazon E-Commerce Service).

For more information on the REST calls, have a look at the whole [Amazon E-Commerce-API](http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html).

Have a look at the [RDOC](http://rdoc.info/projects/phoet/asin) for this project, if you like browsing some docs.

The gem runs smoothly with Rails and is tested against multiple rubies. See *.travis.yml* for details.


## Upgrading from Version 1.x

Version 2 removes all the SimpleXXX classes in favor of [Hashie::Rash](https://github.com/tcocca/rash).

The old API is available if you require `ASIN::Adapter`:

```ruby
require 'asin'
require 'asin/adapter'
```

It's also a good starting point for looking into writing your own asin-adapter.


## Installation

```bash
gem install asin
gem install curb # optional, see HTTPI
```

or in your Gemfile:

```ruby
gem 'asin'
gem 'curb' # optional, see HTTPI
```

## Configuration

Rails style initializer (`config/initializers/asin.rb`):

```ruby
ASIN::Configuration.configure do |config|
  config.secret        = 'your-secret'
  config.key           = 'your-key'
  config.associate_tag = 'your-tag'
end
```

Have a look at `ASIN::Configuration` class for all the details.

## Usage

ASIN is designed as a module, so you can include it into any object you like:

```ruby
# require and include
require 'asin'
include ASIN::Client

# lookup an ASIN
lookup '1430218150'

# lookup multiple items by ASIN
lookup ['1430218150','1934356549']
```

But you can also use the *instance* method to get a proxy-object:

```ruby
# just require
require 'asin'

# create an ASIN client
client = ASIN::Client.instance

# lookup an item with the amazon standard identification number (asin)
items = client.lookup '1430218150'

# have a look at the title of the item
items.first.item_attributes.title
# => Learn Objective-C on the Mac (Learn Series)

# search for any kind of stuff on amazon with keywords
items = client.search_keywords 'Learn', 'Objective-C'
items.first.item_attributes.title
# => "Learn Objective-C on the Mac (Learn Series)"

# search for any kind of stuff on amazon with custom parameters
items = client.search :Keywords => 'Learn Objective-C', :SearchIndex => :Books
items.first.item_attributes.title
# => "Learn Objective-C on the Mac (Learn Series)"

# search for similar items like the one you already have
items = client.similar '1430218150'
items.first.item_attributes.title
# => "Beginning iOS 7 Development: Exploring the iOS SDK"
```

There is an additional set of methods to support AWS cart operations:

```ruby
client = ASIN::Client.instance

# create a cart with an item
cart = client.create_cart({:asin => '1430218150', :quantity => 1})
cart.cart_items.cart_item
# => [<#Hashie::Rash ASIN="1430218150" CartItemId="U3G241HVLLB8N6" ... >]

# clear everything from the cart
cart = client.clear_cart(cart)
cart.cart_items.cart_item
# => []

# update items in the cart
cart = client.update_items(cart, {:cart_item_id => cart.items.first.CartItemId, :action => :SaveForLater}, {:cart_item_id # => cart.items.first.CartItemId, :quantity => 7})
cart.saved_for_later_items.saved_for_later_item
# => [<#Hashie::Rash ASIN="1430218150" CartItemId="U3G241HVLLB8N6" ... >]
```

It's also possible to access browse nodes:

```ruby
client = ASIN::Client.instance

# create a cart with an item
node = client.browse_node('17', :ResponseGroup => :TopSellers)
node.first.browse_node_id
# => '163357'
node.first.name
# => 'Literature & Fiction'
```

## HTTPI

ASIN uses [HTTPI](https://github.com/rubiii/httpi) as a HTTP-Client adapter.
See the HTTPI documentation for how to configure different clients or the logger.
As a default HTTPI uses _httpclient_ so you should add that dependency to your project:

```ruby
gem 'httpclient'
```

## Confiture

ASIN uses [Confiture](https://github.com/phoet/confiture) as a Configuration gem.
See the Confiture documentation for different configuration styles.


## License

"THE (extended) BEER-WARE LICENSE" (Revision 42.0815): [phoet](mailto:ps@nofail.de) contributed to this project.

As long as you retain this notice you can do whatever you want with this stuff.
If we meet some day, and you think this stuff is worth it, you can buy me some beers in return.
