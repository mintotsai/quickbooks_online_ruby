require "quickbooks_online_ruby/version"
require 'quickbooks_online_ruby/config'

require "faraday"

module QuickbooksOnlineRuby
  autoload :AbstractClient, 'quickbooks_online_ruby/abstract_client'
  autoload :Middleware,     'quickbooks_online_ruby/middleware'
  autoload :Client,         'quickbooks_online_ruby/client'

  module Concerns
    autoload :Authentication, 'quickbooks_online_ruby/concerns/authentication'
    autoload :Connection,     'quickbooks_online_ruby/concerns/connection'
    autoload :Base,           'quickbooks_online_ruby/concerns/base'
    autoload :API,            'quickbooks_online_ruby/concerns/api'
  end

  module Accounting
    autoload :Client, 'quickbooks_online_ruby/accounting/client'
  end

  Error               = Class.new(StandardError)
  ServerError         = Class.new(Error)
  AuthenticationError = Class.new(Error)
  UnauthorizedError   = Class.new(Error)

  class << self
    # Alias for QuickbooksOnlineRuby::Accounting::Client.new
    #
    # Shamelessly pulled from https://github.com/restforce/restforce/blob/master/lib/restforce.rb
    # who, shamelessly pulled from https://github.com/pengwynn/octokit/blob/master/lib/octokit.rb
    def new(*args, &block)
      accounting(*args, &block)
    end

    def accounting(*args, &block)
      QuickbooksOnlineRuby::Accounting::Client.new(*args, &block)
    end
  end
end
