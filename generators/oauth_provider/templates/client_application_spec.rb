require File.dirname(__FILE__) + '/../spec_helper'

module OAuthSpecHelpers
  include OAuth::TestHelper
  
  def create_consumer
    @consumer=OAuth::Consumer.new({
      :consumer_key=>@application.key,
      :consumer_secret=>@application.secret,
      :site=>@application.oauth_server.base_url
    })
  end
  
  def create_oauth_request
    @token=AccessToken.create :client_application=>@application,:user=>users(:quentin)
    @request=@consumer.signed_request( :get,"/hello",{:oauth_token=>@token.token},@token.secret)
  end
  
  def create_request_token_request
    @request=@consumer.signed_request( :get,@application.oauth_server.request_token_path)
  end
  
  def create_access_token_request
    @token=RequestToken.create :client_application=>@application
    @request=@consumer.signed_request( :get,@application.oauth_server.request_token_path,{:oauth_token=>@token.token},@token.secret)
  end
    
end

describe ClientApplication, :shared=>true do
  before(:each) do
    @application = ClientApplication.create :name=>"Agree2",:url=>"http://agree2.com",:user=>users(:quentin)
    create_consumer
  end

  it "should be valid" do
    @application.should be_valid
  end
  
  it "should have a valid request" do
    @request.should be_signed
    if @token
      @request.verify?(@application.secret, @token.secret).should==true
    else
      @request.verify?(@application.secret).should==true      
    end
  end
    
  it "should not have errors" do
    @application.errors.full_messages.should==[]
  end
  
  it "should have key and secret" do
    @application.key.should_not be_nil
    @application.secret.should_not be_nil
  end

  it "should have credentials" do
    @application.credentials.should_not be_nil
    @application.credentials.key.should==@application.key
    @application.credentials.secret.should==@application.secret
  end
  
end

describe ClientApplication," requesting token" do
  fixtures :users,:client_applications,:oauth_tokens
  include OAuthSpecHelpers
  
  it_should_behave_like "ClientApplication"
   
  before(:each) do
    create_request_token_request
    @incoming=mock_incoming_request_with_query(@request)
  end

  it "should find consumer key for normal request" do
    ClientApplication.find_for_request( @incoming).should==@application
  end

  it "should create a request token" do
    @token=@application.create_request_token(@incoming)
    @token.should_not be_nil
    @token.is_a?(RequestToken).should==true
    @token.token.should_not be_nil
    @token.secret.should_not be_nil
  end
  
end

describe ClientApplication," requesting token using auth header" do
  fixtures :users,:client_applications,:oauth_tokens
  include OAuthSpecHelpers
  
  it_should_behave_like "ClientApplication"
  
  before(:each) do
    create_request_token_request
    @incoming=mock_incoming_request_with_authorize_header(@request)
  end


  it "should find consumer key for request" do
    ClientApplication.find_for_request( @incoming).should==@application
  end

  it "should create a request token" do
    @token=@application.create_request_token(@incoming)
    @token.should_not be_nil
    @token.is_a?(RequestToken).should==true
    @token.token.should_not be_nil
    @token.secret.should_not be_nil
  end

end

describe ClientApplication," with unauthorized request token" do
  fixtures :users,:client_applications,:oauth_tokens
  include OAuthSpecHelpers
  
  it_should_behave_like "ClientApplication"
  
  before(:each) do
    create_access_token_request
    @incoming=mock_incoming_request_with_authorize_header(@request)
  end
  
  it "should not have an authorized token" do
    @token.should_not be_authorized    
  end

  it "should not have an invalidated token" do
    @token.should_not be_invalidated
  end
    
  it "should not create an access token" do
    @application.exchange_for_access_token(@incoming).should==false
  end
  
end

describe ClientApplication," with authorized request token" do
  fixtures :users,:client_applications,:oauth_tokens
  include OAuthSpecHelpers
  
  it_should_behave_like "ClientApplication"
  
  before(:each) do
    create_access_token_request
    @token.authorize!(users(:quentin))
    @incoming=mock_incoming_request_with_authorize_header(@request)
  end
    
  it "should have an authorized token" do
    @token.should be_authorized    
  end

  it "should not have an invalidated token" do
    @token.should_not be_invalidated
  end

  it "should create a request token" do
    @access_token=@application.exchange_for_access_token(@incoming)
    @access_token.class.should==AccessToken
    @access_token.is_a?(AccessToken).should==true
    @access_token.token.should_not be_nil
    @access_token.secret.should_not be_nil
    @access_token.should be_authorized    

    @token.reload
    @token.should be_invalidated
  end
  
end

describe ClientApplication," accessing a resource" do
  fixtures :users,:client_applications,:oauth_tokens
  include OAuthSpecHelpers
  
  it_should_behave_like "ClientApplication"
  
  before(:each) do
    create_oauth_request
    @incoming=mock_incoming_request_with_authorize_header(@request)
    @access_token=ClientApplication.authorize_request?(@incoming)
  end
  
  it "should have a token" do
    @request.token.should_not be_nil
    @token.class.should==AccessToken
    @token.should be_authorized
  end
  
  it "should authorize request" do
    @access_token.should_not==false
  end

  it "should return accesst_token" do
    @access_token.should==@token
  end
  
end
