require 'oauth'
require 'oauth/rails/controller_methods'
ActionController::Base.send :include, OAuth::Rails::ControllerMethods
