require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/request_proxy/rack_request'
require 'oauth/server'
require 'oauth/controllers/application_controller_methods'
require 'oauth/request_proxy/rack_request'

require 'oauth/provider/authorizer'
require 'oauth/provider/models/token'
require 'oauth/provider/models/authorizable'
require 'oauth/provider/models/authorized'
require 'oauth/provider/models/bearer_token'
require 'oauth/provider/models/secret'
require 'oauth/provider/models/short_expiry'
require 'oauth/provider/models/request_token'
require 'oauth/provider/models/verifier'

# TODO this should be manually inserted
module OAuth
  module Provider
    class OAuthRailtie < Rails::Railtie
      initializer "oauth-plugin.configure_rails_initialization" do |app|
        ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
      end
    end
  end
end
