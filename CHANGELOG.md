## 2.0.2

* changes from Hashie::Rash to Hashie::SCHash, because Hashie added its own Rash class that conflicted with the Rash gem.

## 2.0.1

* get rid of OpenSSL deprecation (davelacy) https://github.com/phoet/asin/pull/36

## 2.0.0

* configurable items are no longer supported, in favor of Hashie::Rash, see upgrading instructions

## 1.2.0

* Added more methods to simplify accessing certain nodes. (kyletcarlson) https://github.com/phoet/asin/pull/30

## 1.1.2

* compatibility update https://github.com/phoet/asin/issues/22

## 1.1.1

* fix handling of multiple BrowseNodes https://github.com/phoet/asin/issues/20

## 1.1.0

* remove built-in support for Hashie::Rash
* relax and update gem dependencies

## 1.0.0

* add requirement to associate_tag in configuration
* update to latest API changes

## 0.8.0

* use confiture for configuration
* implement SimilarityLookup https://github.com/phoet/asin/issues/15

## 0.7.0

* jruby compatible
* loosen gem dependencies

## 0.6.1

* fix error when passing nil to config values

## 0.6.0

* change lookup method - pull request https://github.com/phoet/asin/pull/8

## 0.5.1

* fix for https://github.com/phoet/asin/issues/7

## 0.5.0

* move client to own file
* use autoload
* support for Hashie::Rash
* new method browse_node

## 0.4.0

* add configuration option for item/cart class
* add more functionality to item class

## 0.4.0.beta1

* added cart operations
* added yml configuration

## 0.3.0

* add search_keywords method
* open up search method to be more flexible

## 0.2.0

* rails initializer configuration
* rpsec for tests

## 0.1.0

* add logger
* use HTTPI as HTTP-adapter
* use bundler for dependencies
