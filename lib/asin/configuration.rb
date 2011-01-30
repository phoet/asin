module ASIN
  class Configuration
    class << self

      attr_accessor :secret, :key, :host, :logger

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
      #   ASIN::Configuration.configure(:secret => 'your-secret', :key => 'your-key')
      # 
      # ==== Options:
      # 
      # [secret] the API secret key
      # [key] the API access key
      # [host] the host, which defaults to 'webservices.amazon.com'
      # [logger] a different logger than logging to STDERR (nil for no logging)
      # 
      def configure(options={})
        init_config
        if block_given?
          yield self
        else
          options.each do |key, value|
            send(:"#{key}=", value)
          end
        end
        self
      end

      private

      def init_config(force=false)
        return if @init && !force
        @init   = true
        @secret = ''
        @key    = ''
        @host   = 'webservices.amazon.com'
        @logger = Logger.new(STDERR)
      end
    end
  end
end

