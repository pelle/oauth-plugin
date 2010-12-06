require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/rack/oauth_filter'
require 'oauth/request_proxy/rack_request'
require 'oauth/server'
require 'oauth/controllers/application_controller_methods'


module OAuth
  module Plugin
    class OAuthRailtie < Rails::Railtie
      initializer "oauth-plugin.configure_rails_initialization" do |app|
        app.middleware.insert_before ActionDispatch::Cookies, OAuth::Rack::OAuthFilter
        ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
      end
    end
  end
end