module QuickbooksOnlineRuby
  # Faraday middleware that allows for on the fly authentication of requests.
  # When a request fails (a status of 401 is returned), the middleware
  # will attempt to refresh the oauth access token (if a refresh token is
  # present).
  class Middleware::Authentication < QuickbooksOnlineRuby::Middleware
    autoload :Token,    'quickbooks_online_ruby/middleware/authentication/token'

    # Rescue from 401's, authenticate then raise the error again so the client
    # can reissue the request.
    def call(env)
      @app.call(env)
    rescue QuickbooksOnlineRuby::UnauthorizedError
      authenticate!
      raise
    end

    # Internal: Performs the authentication and returns the response body.
    def authenticate!
      response = connection.post '/oauth2/v1/tokens/bearer' do |req|
        req.headers['Authorization'] = 'Basic ' + Base64.strict_encode64(@options[:client_id] + ":" + @options[:client_secret])
        req.body = encode_www_form(params)
      end

      if response.status >= 500
        raise QuickbooksOnlineRuby::ServerError, error_message(response)
      elsif response.status != 200
        raise QuickbooksOnlineRuby::AuthenticationError, error_message(response)
      end

      @options[:access_token]  = response.body['access_token']
      @options[:refresh_token] = response.body['refresh_token']

      if @options[:authentication_callback]
        @options[:authentication_callback].call(response.body)
      end

      response.body
    end

    # Internal: The params to post to the OAuth service.
    def params
      raise NotImplementedError
    end

    # Internal: Faraday connection to use when sending an authentication request.
    def connection
      @connection ||= Faraday.new(faraday_options) do |builder|
        builder.use Faraday::Request::UrlEncoded
        # builder.use QuickbooksOnlineRuby::Middleware::Mashify, nil, @options
        builder.response :json

        if QuickbooksOnlineRuby.log?
          builder.use QuickbooksOnlineRuby::Middleware::Logger,
                      QuickbooksOnlineRuby.configuration.logger,
                      @options
        end

        builder.adapter @options[:adapter]
      end
    end

    # Internal: The parsed error response.
    def error_message(response)
      "#{response.body['error']}: #{response.body['error_description']}"
    end

    # Featured detect form encoding.
    # URI in 1.8 does not include encode_www_form
    def encode_www_form(params)
      if URI.respond_to?(:encode_www_form)
        URI.encode_www_form(params)
      else
        params.map do |k, v|
          k = CGI.escape(k.to_s)
          v = CGI.escape(v.to_s)
          "#{k}=#{v}"
        end.join('&')
      end
    end

    private

    def faraday_options
      { url: "https://#{@options[:oauth_host]}"
      }
    end
  end
end
