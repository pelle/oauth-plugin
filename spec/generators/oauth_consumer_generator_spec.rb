require "generator_spec"
require "generators/oauth_consumer/oauth_consumer_generator"

describe OauthConsumerGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  before(:all) do
    prepare_destination
    prepare_routes
    run_generator %w(oauth_consumer)
  end

  it "creates oauth_consumers initializer" do
    destination_root.should have_structure {
      directory "config" do
          directory "initializers" do
            file "oauth_consumers.rb"
          end
      end
    }
  end
  it "creates oauth_consumers controller" do
    destination_root.should have_structure {
      directory "app" do
        directory "controllers" do
          file "oauth_consumers_controller.rb"
        end
      end
    }
  end
#  it "adds oauth_consumers routes" do
#    #match = /resources :oauth_consumers do/
#    #assert_file "config/routes.rb", match
#    destination_root.should have_structure {
#      directory "config" do
#        file "routes.rb" do
#          contains "resources :oauth_consumers do"
#        end
#      end
#    }
#  end
  
  def prepare_routes
     destination = File.join(destination_root, "config")
     FileUtils.mkdir_p(destination)
     File.open(File.join(destination, "routes.rb"), 'w') { |file| file.truncate(0) }
  end
end