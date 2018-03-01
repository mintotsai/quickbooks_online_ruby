module QuickbooksOnlineRuby
  # Middleware that allows you to specify custom request headers
  # when initializing QuickbooksOnlineRuby client
  class Middleware::CustomHeaders < QuickbooksOnlineRuby::Middleware
    def call(env)
      headers = @options[:request_headers]
      env[:request_headers].merge!(headers) if headers.is_a?(Hash)

      @app.call(env)
    end
  end
end
