# OAuth Plugin

This is a rubygem for implementing OAuth Providers and Consumers in Rails applications.

This is a fork to [https://github.com/pelle/oauth-plugin](https://github.com/pelle/oauth-plugin)

The fixes are to support rails 2.x


## Installation (Rails 2.x)

Gemfile

    gem "oauth-plugin", :git => 'git://github.com/tianhsky/oauth-plugin.git', :branch => 'master'


Run

    ./script/generate oauth_provider

environment.rb

    require 'oauth/rack/oauth_filter'
    config.middleware.use OAuth::Rack::OAuthFilter

User Model

    has_many :client_applications
    has_many :tokens, :class_name => "OauthToken", :order => "authorized_at desc", :include => [:client_application]

Migration

    rake db:migrate

applicatoin_controller.rb

    oauthenticate :strategies => :token , :interactive => true