class OauthConsumerGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  attr_reader   :class_path,
                :controller_name,
                :controller_class_name,

  def initialize(runtime_args, runtime_options = {})
    super
    @controller_name = 'oauth_consumers'
    @controller_class_name="OauthConsumers"
    @class_path=''
  end

  def manifest
    record do |m|
      
      # Check for class naming collisions.
      # Check for class naming collisions.
      m.class_collisions controller_class_path,       "#{controller_class_name}Controller"
      m.class_collisions class_path,                  "ConsumerToken"

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models')
      m.directory File.join('app/controllers')
      m.directory File.join('app/helpers')
      m.directory File.join('app/views', controller_name)
      m.directory File.join('config/initializers')
      
      m.template 'oauth_config.rb',File.join('config/initializers', "oauth_consumers.rb")
      m.template 'consumer_token.rb',File.join('app/models',"consumer_token.rb")

      m.template 'controller.rb',File.join('app/controllers',"#{controller_name}_controller.rb")
      m.route_resources :oauth_consumers,:member=>{:callback=>:get}
      
      @template_extension= options[:haml] ? "haml" : "erb"
      
      m.template "show.html.#{@template_extension}",  File.join('app/views', controller_name, "show.html.#{@template_extension}")
      
      unless options[:skip_migration] 
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "CreateOauthConsumerTokens"
        }, :migration_file_name => "create_oauth_consumer_tokens"
      end
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name}"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file") { |v| options[:skip_migration] = v }
#      opt.on("--test-unit", 
#             "Generate the Test::Unit compatible tests instead of RSpec") { |v| options[:test_unit] = v }
      opt.on("--haml", 
            "Templates use haml") { |v| options[:haml] = v }
    end
end
