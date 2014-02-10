# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy_app/config/environment.rb",  __FILE__)

Rails.backtrace_cleaner.remove_silencers!
