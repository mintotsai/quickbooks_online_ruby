module QuickbooksOnlineRuby
  class AbstractClient
    include QuickbooksOnlineRuby::Concerns::Base
    include QuickbooksOnlineRuby::Concerns::Connection
    include QuickbooksOnlineRuby::Concerns::Authentication
    # include QuickbooksOnlineRuby::Concerns::Caching
    include QuickbooksOnlineRuby::Concerns::API
  end
end
