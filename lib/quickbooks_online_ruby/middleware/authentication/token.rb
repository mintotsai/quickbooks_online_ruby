module QuickbooksOnlineRuby
  # Authentication middleware used if oauth_token and refresh_token are set
  class Middleware::Authentication::Token < QuickbooksOnlineRuby::Middleware::Authentication
    def params
      { grant_type: 'refresh_token',
        refresh_token: @options[:refresh_token] }
    end
  end
end
