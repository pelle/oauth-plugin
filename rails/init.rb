require 'oauth'
require 'oauth/signature/hmac/sha1'
if Rails.version =~ /^3\./
  require 'oauth/request_proxy/rack_request'
else
  require 'oauth/request_proxy/action_controller_request'
end
require 'oauth/server'
require 'oauth/controllers/application_controller_methods'

  ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
