module QuickbooksOnlineRuby
  class Middleware::RaiseError < Faraday::Response::Middleware
    def on_complete(env)
      @env = env
      case env[:status]
      when 300
        raise Faraday::Error::ClientError.new("300: The external ID provided matches " \
                                              "more than one record",
                                              response_values)
      when 401
        raise QuickbooksOnlineRuby::UnauthorizedError, message
      when 404
        raise Faraday::Error::ResourceNotFound, message
      when 413
        raise Faraday::Error::ClientError.new("413: Request Entity Too Large",
                                              response_values)
      when 400...600
        raise Faraday::Error::ClientError.new(message, response_values)
      end
    end

    def message
      "#{body['code']}: #{body['Message']}"
    end

    def body
      @body = (@env[:body]['Fault']['Error'].is_a?(Array) ? @env[:body]['Fault']['Error'].first : @env[:body]['Fault']['Error'])

      case @body
      when Hash
        @body
      else
        { 'errorCode' => '(error code missing)', 'message' => @body }
      end
    end

    def response_values
      {
        status: @env[:status],
        headers: @env[:response_headers],
        body: @env[:body]
      }
    end
  end
end
