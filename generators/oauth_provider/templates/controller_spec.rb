require File.dirname(__FILE__) + '/../spec_helper'

module OAuthControllerSpecHelpers
  def login
    controller.stub!(:local_request?).and_return(true)
    @user=mock_model(User)
    controller.stub!(:current_user).and_return(@user)
    @tokens=[]
    @tokens.stub!(:find).and_return(@tokens)
    @user.stub!(:tokens).and_return(@tokens)
  end
  
  def login_as_application_owner
    login
    @client_application=mock_model(ClientApplication)
    @client_applications=[@client_application]
    
    @user.stub!(:client_applications).and_return(@client_applications)
    @client_applications.stub!(:find).and_return(@client_application)
  end
  
  def setup_oauth
    controller.stub!(:local_request?).and_return(true)
    
    @server=OAuth::Server.new "http://test.host"
    @consumer=@server.create_consumer

    @client_application=mock_model(ClientApplication)
    ClientApplication.stub!(:find_for_request).and_return(@client_application)

    @client_application.stub!(:key).and_return(@consumer.key)
    @client_application.stub!(:secret).and_return(@consumer.secret)
    @client_application.stub!(:name).and_return("Client Application name")
    @client_application.stub!(:callback_url).and_return("http://application/callback")
    @token=mock_model(OauthToken,:token=>'hh5s93j4hdidpola',:client_application=>@client_application,:secret=>"hdhd0244k9j7ao03")
    @token.stub!(:invalidated?).and_return(false)
    
    @token_string="oauth_token=hh5s93j4hdidpola&oauth_token_secret=hdhd0244k9j7ao03"
    @token.stub!(:to_query).and_return(@token_string)

    @client_application.stub!(:authorize_request?).and_return(true)
    @client_application.stub!(:create_request_token).and_return(@token)
    @client_application.stub!(:exchange_for_access_token).and_return(@token)
  end
  
  def setup_oauth_for_user
    login
    setup_oauth
    @tokens=[@token]
    @tokens.stub!(:find).and_return(@tokens)
    @tokens.stub!(:find_by_token).and_return(@token)
    @user.stub!(:tokens).and_return(@tokens)
  end
  
  def create_request(http_method, path, oauth_params={},token_secret=nil,*arguments)
    request=@consumer.signed_request(http_method, path, oauth_params,token_secret,*arguments)
  end
  
  def create_token_request(http_method=:get)
    create_request(http_method,@server.request_token_url)
  end
  
  def setup_to_authorize_request
    setup_oauth
    AccessToken.stub!(:find_by_token).with( @token.token).and_return(@token)
    @token.stub!(:authorized?).and_return(true)
    @user=mock_model(User)
    @token.stub!(:user).and_return(@user)
  end
end

describe OauthController, "getting a request token" do
  include OAuthControllerSpecHelpers
  before(:each) do
    setup_oauth
    @request_token=create_token_request
  end
  
  def do_get
    get :request_token,@request_token.to_hash
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query for client_application" do
    ClientApplication.should_receive(:find_for_request).with(request).and_return(@client_application)
    do_get
  end
  
  it "should request token from client_application" do
    @client_application.should_receive(:create_request_token).and_return(@token)
    do_get
  end
  
  it "should return token string" do
    do_get
    response.body.should==@token_string
  end
end

describe OauthController, "token authorization" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login
    setup_oauth
    @request_token=create_token_request
    RequestToken.stub!(:find_by_token).and_return(@token)
  end
  
  def do_get
    get :authorize,:oauth_token=>@token.token
  end

  def do_post
    @token.should_receive(:authorize!).with(@user)
    post :authorize,:oauth_token=>@token.token,:authorize=>"1"
  end

  def do_post_without_user_authorization
    @token.should_receive(:invalidate!)
    post :authorize,:oauth_token=>@token.token,:authorize=>"0"
  end

  def do_post_with_callback
    @token.should_receive(:authorize!).with(@user)
    post :authorize,:oauth_token=>@token.token,:oauth_callback=>"http://application/alternative",:authorize=>"1"
  end

  def do_post_with_no_application_callback
    @token.should_receive(:authorize!).with(@user)
    @client_application.stub!(:callback_url).and_return(nil)
    post :authorize,:oauth_token=>@token.token,:authorize=>"1"
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query for client_application" do
    RequestToken.should_receive(:find_by_token).and_return(@token)
    do_get
  end
  
  it "should assign token" do
    do_get
    assigns[:token].should equal(@token)
  end
  
  it "should render authorize template" do
    do_get
    response.should render_template('authorize')
  end
  
  it "should redirect to default callback" do
    do_post
    response.should be_redirect
    response.should redirect_to("http://application/callback?oauth_token=#{@token.token}")
  end

  it "should redirect to callback in query" do
    do_post_with_callback
    response.should be_redirect
    response.should redirect_to("http://application/alternative?oauth_token=#{@token.token}")
  end

  it "should be successful on authorize without any application callback" do
    do_post_with_no_application_callback
    response.should be_success
  end

  it "should be successful on authorize without any application callback" do
    do_post_with_no_application_callback
    response.should render_template('authorize_success')
  end
  
  it "should render failure screen on user invalidation" do
    do_post_without_user_authorization
    response.should render_template('authorize_failure')
  end

  it "should render failure screen if token is invalidated" do
    @token.should_receive(:invalidated?).and_return(true)
    do_get
    response.should render_template('authorize_failure')
  end
  

end


describe OauthController, "getting an access token" do
  include OAuthControllerSpecHelpers
  before(:each) do
    setup_oauth
    @request_token=create_token_request
  end
  
  def do_get
    get :access_token,@request_token.to_hash
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query for client_application" do
    ClientApplication.should_receive(:find_for_request).with(request).and_return(@client_application)
    do_get
  end
  
  it "should request token from client_application" do
    @client_application.should_receive(:exchange_for_access_token).and_return(@token)
    do_get
  end
  
  it "should return token string" do
    do_get
    response.body.should==@token_string
  end
end

class OauthorizedController<ApplicationController
  before_filter :login_or_oauth_required,:only=>:both
  before_filter :login_required,:only=>:interactive
  before_filter :oauth_required,:only=>:token_only
  
  def interactive
  end
  
  def token_only
  end
  
  def both
  end
end

describe OauthorizedController," access control" do
  include OAuthControllerSpecHelpers
  
  before(:each) do
  end
  
  it "should return false for oauth? by default" do
    controller.send(:oauth?).should==false
  end

  it "should return nil for current_token  by default" do
    controller.send(:current_token).should be_nil
  end
  
  it "should allow oauth when using login_or_oauth_required" do
    setup_to_authorize_request
    ClientApplication.should_receive(:authorize_request?).and_return(@token)
    @oauth_request=create_request(:get,"/oauthorized/both",{},@token.secret)
    get :both,@oauth_request.to_hash
    controller.send(:current_token).should==@token
    controller.send(:current_user).should==@user
    response.should be_success
  end

  it "should allow interactive when using login_or_oauth_required" do
    login
    get :both
    response.should be_success
    controller.send(:current_user).should==@user
    controller.send(:current_token).should be_nil
  end

  
  it "should allow oauth when using oauth_required" do
    setup_to_authorize_request
    ClientApplication.should_receive(:authorize_request?).and_return(@token)    
    @oauth_request=create_request(:get,"/oauthorized/token_only",{},@token.secret)
    get :token_only,@oauth_request.to_hash
    response.should be_success
    controller.send(:current_user).should==@user
    controller.send(:current_token).should==@token
  end

  it "should disallow interactive when using oauth_required" do
    login
    get :token_only
    response.should be_redirect
    controller.send(:current_user).should==@user
    controller.send(:current_token).should be_nil
  end

  it "should disallow oauth when using login_required" do
    setup_to_authorize_request
    @oauth_request=create_request(:get,"/oauthorized/interactive",{},@token.secret)
    get :interactive,@oauth_request.to_hash
    response.code.should=="302"
    controller.send(:current_user).should==:false
    controller.send(:current_token).should be_nil
  end

  it "should allow interactive when using login_required" do
    login
    get :interactive
    response.should be_success
    controller.send(:current_user).should==@user
    controller.send(:current_token).should be_nil
  end

end

describe OauthController, "revoke" do
  include OAuthControllerSpecHelpers
  before(:each) do
    setup_oauth_for_user
    @token.stub!(:invalidate!)
  end
  
  def do_post
    post :revoke,:token=>"TOKEN STRING"
  end
  
  it "should redirect to index" do
    do_post
    response.should be_redirect
    response.should redirect_to('http://test.host/oauth')
  end
  
  it "should query current_users tokens" do
    @tokens.should_receive(:find_by_token).and_return(@token)
    do_post
  end
  
  it "should call invalidate on token" do
    @token.should_receive(:invalidate!)
    do_post
  end
  
end


describe OauthController, "index" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login_as_application_owner
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query current_users client applications" do
    @user.should_receive(:client_applications).and_return(@client_applications)
    do_get
  end
  
  it "should assign client_applications" do
    do_get
    assigns[:client_applications].should equal(@client_applications)
  end
  
  it "should render index template" do
    do_get
    response.should render_template('index')
  end
end


describe OauthController, "show" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login_as_application_owner
  end
  
  def do_get
    get :show,:id=>'3'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query current_users client applications" do
    @user.should_receive(:client_applications).and_return(@client_applications)
    @client_applications.should_receive(:find).with('3').and_return(@client_application)
    do_get
  end
  
  it "should assign client_applications" do
    do_get
    assigns[:client_application].should equal(@client_application)
  end
  
  it "should render show template" do
    do_get
    response.should render_template('show')
  end
  
end


describe OauthController, "new" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login_as_application_owner
    ClientApplication.stub!(:new).and_return(@client_application)
  end
  
  def do_get
    get :new
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should assign client_applications" do
    do_get
    assigns[:client_application].should equal(@client_application)
  end
  
  it "should render show template" do
    do_get
    response.should render_template('new')
  end
  
end

describe OauthController, "edit" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login_as_application_owner
  end
  
  def do_get
    get :edit,:id=>'3'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query current_users client applications" do
    @user.should_receive(:client_applications).and_return(@client_applications)
    @client_applications.should_receive(:find).with('3').and_return(@client_application)
    do_get
  end
  
  it "should assign client_applications" do
    do_get
    assigns[:client_application].should equal(@client_application)
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
end


describe OauthController, "edit" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login_as_application_owner
  end
  
  def do_get
    get :edit,:id=>'3'
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should query current_users client applications" do
    @user.should_receive(:client_applications).and_return(@client_applications)
    @client_applications.should_receive(:find).with('3').and_return(@client_application)
    do_get
  end
  
  it "should assign client_applications" do
    do_get
    assigns[:client_application].should equal(@client_application)
  end
  
  it "should render edit template" do
    do_get
    response.should render_template('edit')
  end
  
end

describe OauthController, "destroy" do
  include OAuthControllerSpecHelpers
  before(:each) do
    login_as_application_owner
    @client_application.stub!(:destroy)
  end
  
  def do_delete
    delete :destroy,:id=>'3'
  end
    
  it "should query current_users client applications" do
    @user.should_receive(:client_applications).and_return(@client_applications)
    @client_applications.should_receive(:find).with('3').and_return(@client_application)
    do_delete
  end

  it "should destroy client applications" do
    @client_application.should_receive(:destroy)
    do_delete
  end
    
  it "should redirect to list" do
    do_delete
    response.should be_redirect
    response.should redirect_to(:action=>'index')
  end
  
end

describe OauthController, "create" do
  include OAuthControllerSpecHelpers
  
  before(:each) do
    login_as_application_owner
    @client_applications.stub!(:build).and_return(@client_application)
    @client_application.stub!(:save).and_return(true)
  end
  
  def do_valid_post
    @client_application.should_receive(:save).and_return(true)
    post :create,'client_application'=>{'name'=>'my site'}
  end

  def do_invalid_post
    @client_application.should_receive(:save).and_return(false)
    post :create,:client_application=>{:name=>'my site'}
  end
  
  it "should query current_users client applications" do
    @client_applications.should_receive(:build).and_return(@client_application)
    do_valid_post
  end
  
  it "should redirect to new client_application" do
    do_valid_post
    response.should be_redirect
    response.should redirect_to(:action=>"show",:id=>@client_application.id)
  end
  
  it "should assign client_applications" do
    do_invalid_post
    assigns[:client_application].should equal(@client_application)
  end
  
  it "should render show template" do
    do_invalid_post
    response.should render_template('new')
  end
end

describe OauthController, "update" do
  include OAuthControllerSpecHelpers
  
  before(:each) do
    login_as_application_owner
  end
  
  def do_valid_update
    @client_application.should_receive(:update_attributes).and_return(true)
    put :update,:id=>'1', 'client_application'=>{'name'=>'my site'}
  end

  def do_invalid_update
    @client_application.should_receive(:update_attributes).and_return(false)
    put :update,:id=>'1', 'client_application'=>{'name'=>'my site'}
  end
  
  it "should query current_users client applications" do
    @user.should_receive(:client_applications).and_return(@client_applications)
    @client_applications.should_receive(:find).with('1').and_return(@client_application)
    do_valid_update
  end
  
  it "should redirect to new client_application" do
    do_valid_update
    response.should be_redirect
    response.should redirect_to(:action=>"show",:id=>@client_application.id)
  end
  
  it "should assign client_applications" do
    do_invalid_update
    assigns[:client_application].should equal(@client_application)
  end
  
  it "should render show template" do
    do_invalid_update
    response.should render_template('edit')
  end
end
