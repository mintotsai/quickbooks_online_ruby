module QuickbooksOnlineRuby
  # Base class that all middleware can extend. Provides some convenient helper
  # functions.
  class Middleware < Faraday::Middleware
    autoload :RaiseError,     'quickbooks_online_ruby/middleware/raise_error'
    autoload :Authentication, 'quickbooks_online_ruby/middleware/authentication'
    autoload :Authorization,  'quickbooks_online_ruby/middleware/authorization'
    autoload :AccessToken,    'quickbooks_online_ruby/middleware/access_token'
    #autoload :Mashify,        'quickbooks_online_ruby/middleware/mashify'
    #autoload :Caching,        'quickbooks_online_ruby/middleware/caching'
    autoload :Logger,         'quickbooks_online_ruby/middleware/logger'
    autoload :CustomHeaders,  'quickbooks_online_ruby/middleware/custom_headers'

    def initialize(app, client, options)
      @app = app
      @client = client
      @options = options
    end

    # Internal: Proxy to the client.
    def client
      @client
    end

    # Internal: Proxy to the client's faraday connection.
    def connection
      client.send(:connection)
    end
  end
end
