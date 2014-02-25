require "generator_spec"
require "generators/oauth_provider/oauth_provider_generator"

describe OauthProviderGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  before(:each) do
    prepare_destination
    prepare_routes
  end

  context "simple models" do
    before(:each) do
      run_generator %w(monster)
    end
    context "controllers" do
      it "creates the model controller" do
        assert_file "app/controllers/monster_controller.rb"
      end
      it "creates the model client controller" do
        assert_file "app/controllers/monster_clients_controller.rb"
      end
    end
  end

  context "namespaced models" do
    before(:each) do
      run_generator %w(monster/goblin)
    end
    context "controllers" do
      it "creates the model controller" do
        assert_file "app/controllers/monster/goblin_controller.rb"
      end
      it "creates the model client controller" do
        assert_file "app/controllers/monster/goblin_clients_controller.rb"
      end
    end
  end
  
#  context "routes" do
#    it "creates the client route" do
#      assert_file "config/routes.rb", "resources :monster_clients"
#    end
#  end
  
  def prepare_routes
     destination = File.join(destination_root, "config")
     FileUtils.mkdir_p(destination)
     File.open(File.join(destination, "routes.rb"), 'w') { |file| file.truncate(0) }
  end
end