require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/rack/oauth_filter'
require 'oauth/server'
require 'oauth/controllers/application_controller_methods'
if Rails.version =~ /^2\./
  require 'oauth/request_proxy/action_controller_request'
  ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
end
