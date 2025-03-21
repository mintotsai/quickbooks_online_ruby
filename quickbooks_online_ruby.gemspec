# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quickbooks_online_ruby/version'

Gem::Specification.new do |gem|
  gem.name          = "quickbooks_online_ruby"
  gem.version       = QuickbooksOnlineRuby::VERSION
  gem.authors       = ["Minto Tsai"]
  gem.email         = ["mintotsai@jasminepm.com"]

  gem.summary       = 'A lightweight ruby client for the Quickbooks Online REST API.'
  gem.description   = 'A lightweight ruby client for the Quickbooks Online REST API.'
  gem.homepage      = "https://github.com"
  gem.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if gem.respond_to?(:metadata)
  #  gem.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  # end

  gem.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.0'

  gem.add_dependency 'faraday', '~> 2.9'
  gem.add_dependency "faraday-follow_redirects"
  gem.add_dependency "faraday-multipart"
  gem.add_dependency "faraday-net_http"

  gem.add_dependency 'json', '>= 1.7.5'

  gem.add_dependency 'hashie', ['>= 1.2.0', '< 4.0']

  gem.add_development_dependency "bundler", "~> 1.13"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency 'rspec', '~> 2.14.0'
end
