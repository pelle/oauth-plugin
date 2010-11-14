require 'rails/generators/migration'
require 'rails/generators/active_record'

class OauthConsumerGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  
  hook_for :orm
    
  class_option 'haml',      :type => :boolean, :default => false,
                            :desc => 'Use Haml for views'
  # class_option 'test-unit', :type => :boolean, :default => false,
  #                             :desc => 'Use Test::Unit for tests (instead of RSpec)'
  
  def copy_models
    template 'oauth_config.rb',   File.join('config', 'initializers', 'oauth_consumers.rb')
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
  
end
