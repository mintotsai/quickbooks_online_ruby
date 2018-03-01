module QuickbooksOnlineRuby
  # Middleware which asserts that the access_token is always set
  class Middleware::AccessToken < QuickbooksOnlineRuby::Middleware
    def call(env)
      # If the connection access_token isn't set, we must not be authenticated.
      unless access_token_set?
        raise QuickbooksOnlineRuby::UnauthorizedError,
              'Access token not set'
      end

      @app.call(env)
    end

    def access_token_set?
      !@options[:access_token].blank?
    end
  end
end
