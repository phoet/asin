require "yaml"
require 'logger'

module ASIN
  class Configuration
    class << self

      attr_accessor :secret, :key, :host, :logger
      attr_accessor :item_type, :cart_type, :node_type
      attr_accessor :version, :associate_tag

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
      # You may pass options as a hash as well:
      #
      #   ASIN::Configuration.configure :secret => 'your-secret', :key => 'your-key'
      #
      # Or configure everything using YAML:
      #
      #   ASIN::Configuration.configure :yaml => 'config/asin.yml'
      #
      #   ASIN::Configuration.configure :yaml => 'config/asin.yml' do |config, yml|
      #     config.key = yml[Rails.env]['aws_access_key']
      #   end
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
      def configure(options={})
        init_config
        if yml_path = options[:yaml] || options[:yml]
          yml = File.open(yml_path) { |file| YAML.load(file) }
          if block_given?
            yield self, yml
          else
            yml.each do |key, value|
              send(:"#{key}=", value)
            end
          end
        elsif block_given?
          yield self
        else
          options.each do |key, value|
            send(:"#{key}=", value)
          end
        end
        self
      end

      # Checks if given credentials are valid and raises an error if not.
      #
      def validate_credentials!
        raise "you have to configure ASIN: 'configure :secret => 'your-secret', :key => 'your-key'" if blank?(:secret) || blank?(:key)
        [:host, :item_type, :cart_type, :node_type, :version, :associate_tag].each { |item| raise "nil is not a valid value for #{item}" unless self.send item }
      end

      # Resets configuration to defaults
      #
      def reset
        init_config(true)
      end

      # Check if a key is set
      #
      def blank?(key)
        val = self.send :key
        val.nil? || val.empty?
      end

      private()

      def init_config(force=false)
        return if @init && !force
        @init          = true
        @secret        = ''
        @key           = ''
        @host          = 'webservices.amazon.com'
        @logger        = Logger.new(STDERR)
        @item_type     = SimpleItem
        @cart_type     = SimpleCart
        @node_type     = SimpleNode
        @version       = '2010-11-01'
        @associate_tag = ''
      end
    end
  end
end
