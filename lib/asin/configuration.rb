require "logger"
require "confiture"

module ASIN

  # Rails initializer configuration.
  #
  # Expects at least +secret+ and +key+ for the API call:
  #
  #   ASIN::Configuration.configure do |config|
  #     config.secret = 'your-secret'
  #     config.key    = 'your-key'
  #   end
  #
  # With the latest version of the Product Advertising API you need to include your associate_tag[https://affiliate-program.amazon.com/gp/advertising/api/detail/api-changes.html].
  #
  # Confiture is used as a basis for configuration. Have a look at the documentation[https://github.com/phoet/confiture] for more configuration styles.
  #
  # ==== Options:
  #
  # [secret] the API secret key (required)
  # [key] the API access key (required)
  # [associate_tag] your Amazon associate tag. Default is blank (required in latest API version)
  # [host] the host, which defaults to 'webservices.amazon.com'
  # [logger] a different logger than logging to STDERR (nil for no logging)
  # [version] a custom version of the API calls. Default is 2010-11-01
  # [item_type] a different class for SimpleItem, use :mash / :rash for Hashie::Mash / Hashie::Rash or :raw for a plain hash
  # [cart_type] a different class for SimpleCart, use :mash / :rash for Hashie::Mash / Hashie::Rash or :raw for a plain hash
  # [node_type] a different class for SimpleNode, use :mash / :rash for Hashie::Mash / Hashie::Rash or :raw for a plain hash
  #
  class Configuration
    include Confiture::Configuration
    confiture_allowed_keys(:secret, :key, :host, :version, :associate_tag, :logger, :item_type, :cart_type, :node_type)
    confiture_mandatory_keys(:secret, :key)
    confiture_defaults({
      :secret        => '',
      :key           => '',
      :host          => 'webservices.amazon.com',
      :version       => '2010-11-01',
      :associate_tag => '',
      :logger        => Logger.new(STDERR),
      :item_type     => SimpleItem,
      :cart_type     => SimpleCart,
      :node_type     => SimpleNode,
    })
  end
end
