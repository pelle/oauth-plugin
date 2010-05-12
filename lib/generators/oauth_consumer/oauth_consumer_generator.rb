require 'rails/generators/migration'
require 'generators/active_record'

class OauthConsumerGenerator < Rails::Generators::Base
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
  # class_option 'test-unit', :type => :boolean, :default => false,
  #                             :desc => 'Use Test::Unit for tests (instead of RSpec)'
  
  def copy_models
    template 'oauth_config.rb',   File.join('config', 'initializers', 'oauth_consumers.rb')
    template 'consumer_token.rb', File.join('app', 'models', 'consumer_token.rb')
  end
  
  def copy_controller
    template 'controller.rb', File.join('app', 'controllers', 'oauth_consumers_controller.rb')
  end
  
  def add_route
    route <<-ROUTE.strip
resources :oauth_consumers do
    get :callback, :on => :member
  end
ROUTE
  end
  
  def copy_views
    @template_extension = options.haml? ? "haml" : "erb"
    
    template "show.html.#{@template_extension}",  File.join('app', 'views', 'oauth_consumers', "show.html.#{@template_extension}")
    template "index.html.#{@template_extension}", File.join('app', 'views', 'oauth_consumers', "index.html.#{@template_extension}")
  end
  
  def copy_migration_file
    return unless options.migration?
    migration_template 'migration.rb', 'db/migrate/create_oauth_consumer_tokens'
  end
end
