require 'bundler'
Bundler::GemHelper.install_tasks

APP_RAKEFILE = File.expand_path("../spec/dummy_app/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
