require "yaml"
require 'logger'

module ASIN
  class Configuration
    class << self

      attr_accessor :secret, :key, :host, :logger
      attr_accessor :item_type, :cart_type

      # Rails initializer configuration.
      #
      # Expects at least +secret+ and +key+ for the API call:
      #
      #   ASIN::Configuration.configure do |config|
      #     config.secret = 'your-secret'
      #     config.key = 'your-key'
      #   end
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
      # [secret] the API secret key
      # [key] the API access key
      # [host] the host, which defaults to 'webservices.amazon.com'
      # [logger] a different logger than logging to STDERR (nil for no logging)
      # [item_type] a different class for SimpleItem, use :mash / :rash for Hashie::Mash / Hashie::Rash or :raw for a plain hash
      # [cart_type] a different class for SimpleCart, use :mash / :rash for Hashie::Mash / Hashie::Rash or :raw for a plain hash
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

      # Resets configuration to defaults
      #
      def reset
        init_config(true)
      end

      private

        def init_config(force=false)
          return if @init && !force
          @init       = true
          @secret     = ''
          @key        = ''
          @host       = 'webservices.amazon.com'
          @logger     = Logger.new(STDERR)
          @item_type  = SimpleItem
          @cart_type  = SimpleCart
        end
    end
  end
end
