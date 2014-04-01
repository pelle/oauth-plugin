require 'generators/oauth_inflections'

class OauthProviderGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  argument :name, :type => :string, :default => 'Oauth'

  desc 'This creates an OAuth Provider controller as well as the requisite models.'

  hook_for :orm

  def check_class_collisions
    # Check for class naming collisions.
    class_collisions class_path, "#{class_name}Controller", # Oauth Controller
                                 "#{class_name}Helper",
                                 "#{class_name}ClientsController",
                                 "#{class_name}ClientsHelper"
  end

  def copy_controller_files
    template 'controller.rb',         File.join('app/controllers', class_path, "#{file_name}_controller.rb")
    template 'clients_controller.rb', File.join('app/controllers', class_path, "#{file_name}_clients_controller.rb")
  end

  def copy_locale
    copy_file "../../../../config/locales/provider.en.yml", "config/locales/oauth-plugin-provider.en.yml"
  end

  hook_for :test_framework, :template_engine

  def add_routes
    route "get   '/oauth',               :to => 'oauth#index',         :as => :oauth"
    route "match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize,    :via => [:get, :post]"
    route "get   '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token"
    route "get   '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token"
    route "get   '/oauth/token',         :to => 'oauth#token',         :as => :token"
    route "get   '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request"

    route "resources :#{file_name}_clients"
  end
end
