module QuickbooksOnlineRuby
  class Middleware::RaiseError < Faraday::Middleware
    def on_complete(env)
      @env = env
      case env[:status]
      when 300
        raise Faraday::Error::ClientError.new(
          "300: The external ID provided matches more than one record",
          response_values
        )
      when 401
        raise QuickbooksOnlineRuby::UnauthorizedError, message
      when 404
        raise Faraday::Error::ResourceNotFound, message
      when 413
        raise Faraday::Error::ClientError.new("413: Request Entity Too Large", response_values)
      when 400...600
        raise Faraday::Error::ClientError.new(message, response_values)
      end
    end

    def message
      err = body
      code = err['code'] || '(error code missing)'
      msg  = err['Message'] || err['message'] || 'No error message provided'
      "#{code}: #{msg}"
    end

    def body
      raw_body = @env[:body]
      return { 'code' => '(error code missing)', 'Message' => 'No response body' } if raw_body.nil?

      if raw_body.is_a?(Hash)
        # Try both capitalized and lowercase keys for 'fault' and 'error'
        fault = raw_body['Fault'] || raw_body['fault']
        if fault && (fault['Error'] || fault['error'])
          error_data = fault['Error'] || fault['error']
          error_item = error_data.is_a?(Array) ? error_data.first : error_data
          return error_item.is_a?(Hash) ? error_item : { 'code' => '(error code missing)', 'Message' => error_item.to_s }
        else
          return {
            'code'    => raw_body['code'] || '(error code missing)',
            'Message' => raw_body['Message'] || raw_body.to_s
          }
        end
      else
        { 'code' => '(error code missing)', 'Message' => raw_body.to_s }
      end
    end

    def response_values
      {
        status:  @env[:status],
        headers: @env[:response_headers],
        body:    @env[:body]
      }
    end
  end
end
