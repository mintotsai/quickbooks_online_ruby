module QuickbooksOnlineRuby
  # Piece of middleware that simply injects the OAuth token into the request
  # headers.
  class Middleware::Authorization < QuickbooksOnlineRuby::Middleware
    AUTH_HEADER = 'Authorization'.freeze

    def call(env)
      env[:request_headers][AUTH_HEADER] = %(Bearer #{token})
      @app.call(env)
    end

    def token
      @options[:access_token]
    end
  end
end
