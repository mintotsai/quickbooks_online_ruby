module QuickbooksOnlineRuby
  module Concerns
    module Base
      attr_reader :options

      # Public: Creates a new client instance
      #
      # opts - A hash of options to be passed in (default: {}).
      #
      #        :access_token            - The String oauth access token to authenticate
      #                                   API calls (required unless password
      #                                   authentication is used).
      #        :refresh_token           - The String refresh token to obtain fresh
      #                                   OAuth access tokens (required if oauth
      #                                   authentication is used).
      #
      #        :client_id               - The oauth client id to use. Needed for both
      #                                   password and oauth authentication
      #        :client_secret           - The oauth client secret to use.
      #
      #        :realm_id                - The realm id to use.
      #
      #        :authentication_retries  - The number of times that client
      #                                   should attempt to reauthenticate
      #                                   before raising an exception (default: 3).
      #
      #        :timeout                 - Faraday connection request read/open timeout.
      #                                   (default: nil).
      #
      #        :authentication_callback - A Proc that is called with the response body
      #                                   after a successful authentication.
      #
      #        :request_headers         - A hash containing custom headers that will be
      #                                   appended to each request

      def initialize(opts = {})
        raise ArgumentError, 'Please specify a hash of options' unless opts.is_a?(Hash)

        @options = Hash[QuickbooksOnlineRuby.configuration.options.map do |option|
          [option, QuickbooksOnlineRuby.configuration.send(option)]
        end]

        @options.merge! opts
        yield builder if block_given?
      end

      def inspect
        "#<#{self.class} @options=#{@options.inspect}>"
      end
    end
  end
end
