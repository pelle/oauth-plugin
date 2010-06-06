require 'rails/generators/migration'
require 'rails/generators/active_record'

class OauthProviderGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  def self.source_root
    @_oauth_plugin_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end
  
  def self.orm_has_migration?
    Rails::Generators.options[:rails][:orm] == :active_record
  end
  
  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end
  
  class_option 'migration', :type => :boolean, :default => orm_has_migration?,
                            :desc => 'Generate a migration file'
  class_option 'haml',      :type => :boolean, :default => false,
                            :desc => 'Use Haml for views'
  class_option 'test-unit', :type => :boolean, :default => false,
                            :desc => 'Use Test::Unit for tests (instead of RSpec)'
  
  attr_reader   :class_path,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name

  def initialize(runtime_args, runtime_options = {}, runtime_config = {})
    super

    @controller_name = runtime_args.shift || 'oauth'
    @controller_singular_name = 'oauth'
    @controller_plural_name = 'oauth'
    @controller_file_name = 'oauth'
    @controller_class_name="Oauth"
    @class_path=''
    @controller_class_path=''
  end

  def check_class_collisions
    # Check for class naming collisions.
    class_collisions controller_class_path, "#{controller_class_name}Controller", # Oauth Controller
                                            "#{controller_class_name}Helper",
                                            "#{controller_class_name}ClientsController",
                                            "#{controller_class_name}ClientsHelper"
    class_collisions class_path,            "ClientApplication","OauthNonce","RequestToken","AccessToken","OauthToken"
  end
  
  def copy_models
    template 'client_application.rb',File.join('app/models',"client_application.rb")
    template 'oauth_token.rb',    File.join('app/models',"oauth_token.rb")
    template 'request_token.rb',  File.join('app/models',"request_token.rb")
    template 'access_token.rb',   File.join('app/models',"access_token.rb")
    template 'oauth2_token.rb',   File.join('app/models',"oauth2_token.rb")
    template 'oauth2_verifier.rb',File.join('app/models',"oauth2_verifier.rb")
    template 'oauth_nonce.rb',    File.join('app/models',"oauth_nonce.rb")
  end
  
  def copy_controllers
    template 'controller.rb',File.join('app/controllers',controller_class_path,"#{controller_file_name}_controller.rb")
    template 'clients_controller.rb',File.join('app/controllers',controller_class_path,"#{controller_file_name}_clients_controller.rb")
  end
  
  def add_routes
    route "match '/oauth',               :to => 'oauth#index',         :as => :oauth"
    route "match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize"
    route "match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token"
    route "match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token"
    route "match '/oauth/token',         :to => 'oauth#token',         :as => :token"
    route "match '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request"

    route "resources :#{controller_file_name}_clients"
  end
  
  def copy_tests
    unless options['test-unit']
      template 'client_application_spec.rb',File.join('spec/models',"client_application_spec.rb")
      template 'oauth_token_spec.rb',    File.join('spec/models',"oauth_token_spec.rb")
      template 'oauth2_token_spec.rb',    File.join('spec/models',"oauth2_token_spec.rb")
      template 'oauth2_verifier_spec.rb', File.join('spec/models',"oauth2_verifier_spec.rb")
      template 'oauth_nonce_spec.rb',    File.join('spec/models',"oauth_nonce_spec.rb")
      template 'client_applications.yml',File.join('spec/fixtures',"client_applications.yml")
      template 'oauth_tokens.yml',    File.join('spec/fixtures',"oauth_tokens.yml")
      template 'oauth_nonces.yml',    File.join('spec/fixtures',"oauth_nonces.yml")
      template 'controller_spec_helper.rb', File.join('spec/controllers', controller_class_path,"#{controller_file_name}_controller_spec_helper.rb")
      template 'controller_spec.rb',File.join('spec/controllers',controller_class_path,"#{controller_file_name}_controller_spec.rb")      
      template 'clients_controller_spec.rb',File.join('spec/controllers',controller_class_path,"#{controller_file_name}_clients_controller_spec.rb")
    else
      template 'client_application_test.rb',File.join('test/unit',"client_application_test.rb")
      template 'oauth_token_test.rb',    File.join('test/unit',"oauth_token_test.rb")
      template 'oauth_nonce_test.rb',    File.join('test/unit',"oauth_nonce_test.rb")
      template 'client_applications.yml',File.join('test/fixtures',"client_applications.yml")
      template 'oauth_tokens.yml',    File.join('test/fixtures',"oauth_tokens.yml")
      template 'oauth_nonces.yml',    File.join('test/fixtures',"oauth_nonces.yml")
      template 'controller_test_helper.rb', File.join('test', controller_class_path,"#{controller_file_name}_controller_test_helper.rb")
      template 'controller_test.rb',File.join('test/functional',controller_class_path,"#{controller_file_name}_controller_test.rb")
      template 'clients_controller_test.rb',File.join('test/functional',controller_class_path,"#{controller_file_name}_clients_controller_test.rb")
    end
  end

  def copy_views
    @template_extension = options.haml? ? "haml" : "erb"

    template "_form.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "_form.html.#{@template_extension}")
    template "new.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "new.html.#{@template_extension}")
    template "index.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "index.html.#{@template_extension}")
    template "show.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "show.html.#{@template_extension}")
    template "edit.html.#{@template_extension}",  File.join('app/views', controller_class_path, 'oauth_clients', "edit.html.#{@template_extension}")
    template "authorize.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "authorize.html.#{@template_extension}")
    template "oauth2_webserver_authorize.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "oauth2_webserver_authorize.html.#{@template_extension}")
    template "authorize_success.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "authorize_success.html.#{@template_extension}")
    template "authorize_failure.html.#{@template_extension}",  File.join('app/views', controller_class_path, controller_file_name, "authorize_failure.html.#{@template_extension}")
  end
  
  def copy_migration_file
    return unless options.migration?
    migration_template 'migration.rb', 'db/migrate/create_oauth_tables'
  end
end