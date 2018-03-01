require 'logger'

module QuickbooksOnlineRuby
  class << self
    attr_writer :log

    # Returns the current Configuration
    #
    # Example
    #
    #    QuickbooksOnlineRuby.configuration.client_id = "client_id"
    #    QuickbooksOnlineRuby.configuration.client_secret = "client_secret"
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the Configuration
    #
    # Example
    #
    #    QuickbooksOnlineRuby.configure do |config|
    #      config.client_id = "client_id"
    #      config.client_secret = "client_secret"
    #    end
    def configure
      yield configuration
    end

    def log?
      @log ||= false
    end

    def log(message)
      return unless QuickbooksOnlineRuby.log?
      configuration.logger.send(configuration.log_level, message)
    end
  end

  class Configuration
    class Option
      attr_reader :configuration, :name, :options

      def self.define(*args)
        new(*args).define
      end

      def initialize(configuration, name, options = {})
        @configuration = configuration
        @name = name
        @options = options
        @default = options.fetch(:default, nil)
      end

      def define
        write_attribute
        define_method if default_provided?
        self
      end

      private

      attr_reader :default
      alias default_provided? default

      def write_attribute
        configuration.send :attr_accessor, name
      end

      def define_method
        our_default = default
        our_name    = name
        configuration.send :define_method, our_name do
          instance_variable_get(:"@#{our_name}") ||
            instance_variable_set(
              :"@#{our_name}",
              our_default.respond_to?(:call) ? our_default.call : our_default
            )
        end
      end
    end

    class << self
      attr_accessor :options

      def option(*args)
        option = Option.define(self, *args)
        (self.options ||= []) << option.name
      end
    end

    # The OAuth client id
    option :client_id, default: lambda { ENV['QBO_CLIENT_ID'] }

    # The OAuth client secret
    option :client_secret, default: lambda { ENV['QBO_CLIENT_SECRET'] }

    option :oauth_host, default: lambda { ENV['QBO_OAUTH_HOST'] || 'oauth.platform.intuit.com' }

    option :use_production, default: false

    option :accounting_sandbox_host, default: lambda { ENV['QBO_ACCOUNTING_SANDBOX_HOST'] || 'sandbox-quickbooks.api.intuit.com' }
    option :payments_sandbox_host, default: lambda { ENV['QBO_PAYMENTS_SANDBOX_HOST'] || 'sandbox.api.intuit.com' }

    option :accounting_production_host, default: lambda { ENV['QBO_ACCOUNTING_PRODUCTION_HOST'] || 'quickbooks.api.intuit.com' }
    option :payments_production_host, default: lambda { ENV['QBO_PAYMENTS_PRODUCTION_HOST'] || 'api.intuit.com' }

    option :access_token
    option :refresh_token
    option :realm_id

    # The number of times reauthentication should be tried before failing.
    option :authentication_retries, default: 3

    # Faraday request read/open timeout.
    option :timeout

    # Faraday adapter to use. Defaults to Faraday.default_adapter.
    option :adapter, default: lambda { Faraday.default_adapter }

    # A Proc that is called with the response body after a successful authentication.
    option :authentication_callback

    # A Hash that is converted to HTTP headers
    option :request_headers

    # Set a logger for when QuickbooksOnlineRuby.log is set to true, defaulting to STDOUT
    option :logger, default: ::Logger.new(STDOUT)

    # Set a log level for logging when QuickbooksOnlineRuby.log is set to true, defaulting to :debug
    option :log_level, default: :debug

    def options
      self.class.options
    end
  end
end
