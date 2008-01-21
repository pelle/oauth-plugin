gem 'oauth','0.1.1'
require 'oauth/rails/controller_methods'
ActionController::Base.send :include, OAuth::Rails::ControllerMethods
