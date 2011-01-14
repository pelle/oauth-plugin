require 'spec_helper'
require 'rack/test'
require 'oauth/rack/oauth_filter'
require 'multi_json'
require 'forwardable'
class OAuthEcho
  def call(env)
    response = {}
    response[:oauth_token] = env["oauth.token"].token if env["oauth.token"]
    response[:client_application] = env["oauth.client_application"].key if env["oauth.client_application"]
    response[:oauth_version] = env["oauth.version"] if env["oauth.version"]
     [200 ,{"Accept"=>"application/json"}, [MultiJson.encode(response)] ]
  end
end

# Dummy implementation
class ClientApplication
  attr_accessor :key

  def self.find_by_key(key)
    ClientApplication.new(key)
  end

  def initialize(key)
    @key = key
  end

  def secret
    "secret"
  end
end

class OauthToken
  attr_accessor :token

  def self.find_by_token(token)
    OauthToken.new(token)
  end

  def initialize(token)
    @token = token
  end

  def secret
    "secret"
  end
end

class Oauth2Token < OauthToken ; end

class OauthNonce
  # Always remember
  def self.remember(nonce,timestamp)
    true
  end
end

describe OAuth::Rack::OAuthFilter do
  include Rack::Test::Methods

  def app
    @app ||= OAuth::Rack::OAuthFilter.new(OAuthEcho.new)
  end

  it "should pass through without oauth" do
    get '/'
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {}
  end

#  it "should sign with consumer" do
#    consumer = "consumer"
#    get '/'
#    last_response.should be_ok
#    response = MultiJson.decode(last_response.body)
#    response.should == {"client_application" => consumer}
#  end

  it "should authenticate with oauth2 auth header" do
    get '/',{},{"HTTP_AUTHORIZATION"=>"OAuth my_token"}
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"oauth_token" => "my_token", "oauth_version"=>2}
  end

  it "should authenticate with pre draft 10 oauth2 auth header" do
    get '/',{},{"HTTP_AUTHORIZATION"=>"Token my_token"}
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"oauth_token" => "my_token", "oauth_version"=>2}
  end

  it "should authenticate with oauth2 query parameter" do
    get '/?oauth_token=my_token'
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"oauth_token" => "my_token", "oauth_version"=>2}
  end

  it "should authenticate with oauth2 post parameter" do
    post '/', :oauth_token=>'my_token'
    last_response.should be_ok
    response = MultiJson.decode(last_response.body)
    response.should == {"oauth_token" => "my_token", "oauth_version"=>2}
  end


end