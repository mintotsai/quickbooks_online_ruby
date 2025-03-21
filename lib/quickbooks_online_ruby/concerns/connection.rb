module QuickbooksOnlineRuby
  module Concerns
    module Connection
      # Public: The Faraday::Builder instance used for the middleware stack. This
      # can be used to insert an custom middleware.
      #
      # Examples
      #
      #   # Add the instrumentation middleware for Rails.
      #   client.middleware.use FaradayMiddleware::Instrumentation
      #
      # Returns the Faraday::Builder for the Faraday connection.
      def middleware
        connection.builder
      end
      alias builder middleware

      private

      # Internal: Internal faraday connection where all requests go through
      def connection
        @connection ||= Faraday.new(connection_options) do |builder|
          # Parses JSON into Hashie::Mash structures.
          # unless options[:mashify] == false
          #  builder.use    QuickbooksOnlineRuby::Middleware::Mashify, self, options
          # end

          # Handles multipart file uploads for blobs.
          # builder.use      QuickbooksOnlineRuby::Middleware::Multipart
          # Converts the request into JSON.
          builder.request  :json
          # Handles reauthentication for 403 responses.
          if authentication_middleware
            builder.use    authentication_middleware, self, options
          end
          # Sets the oauth token in the headers.
          builder.use      QuickbooksOnlineRuby::Middleware::Authorization, self, options
          # Ensures the instance url is set.
          # builder.use      QuickbooksOnlineRuby::Middleware::InstanceURL, self, options
          # Ensures the instance url is set.
          builder.use      QuickbooksOnlineRuby::Middleware::AccessToken, self, options
          # Caches GET requests.
          # builder.use      QuickbooksOnlineRuby::Middleware::Caching, cache, options if cache
          # Follows 30x redirects.
          builder.use Faraday::FollowRedirects::Middleware, limit: 3
          # Raises errors for 40x responses.
          builder.use      QuickbooksOnlineRuby::Middleware::RaiseError
          # Parses returned JSON response into a hash.
          builder.response :json, content_type: /\bjson$/
          # Compress/Decompress the request/response
          # builder.use      QuickbooksOnlineRuby::Middleware::Gzip, self, options
          # Inject custom headers into requests
          builder.use      QuickbooksOnlineRuby::Middleware::CustomHeaders, self, options
          # Log request/responses
          if QuickbooksOnlineRuby.log?
            builder.use      QuickbooksOnlineRuby::Middleware::Logger,
                             QuickbooksOnlineRuby.configuration.logger,
                             options
          end

          builder.adapter adapter
        end
      end

      def adapter
        options[:adapter]
      end

      # Internal: Faraday Connection options
      def connection_options
        connection_options = { request: {
            timeout: options[:timeout],
            open_timeout: options[:timeout]
          },
          headers: {
            accept: 'application/json'
          },
        }

        if !@options[:use_production]
          connection_options[:url] = "https://#{@options[:accounting_sandbox_host]}"
        else
          connection_options[:url] = "https://#{@options[:accounting_production_host]}"
        end

        connection_options
      end
    end
  end
end
