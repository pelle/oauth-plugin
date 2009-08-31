class GoogleToken < ConsumerToken
  GOOGLE_SETTINGS={
    :site=>"https://www.google.com", 
    :request_token_path => "/accounts/OAuthGetRequestToken",
    :authorize_path => "/accounts/OAuthAuthorizeToken",
    :access_token_path => "/accounts/OAuthGetAccessToken",
  }
  
  def self.consumer
    @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],GOOGLE_SETTINGS
  end 
  
  def self.get_request_token(callback_url, scope)
    consumer.get_request_token({:oauth_callback=>callback_url}, :scope=>scope)
  end
  
  def self.create_from_request_token(user,token,secret,oauth_verifier)
    logger.info "create_from_request_token"
    request_token=OAuth::RequestToken.new consumer,token,secret    
    # Get access token via oauth or Google federated login (hybrid OpenID/OAuth) which doesn't require a oauth_verifier parameter
    access_token=(oauth_verifier && request_token.get_access_token(:oauth_verifier=>oauth_verifier)) || request_token.get_access_token
    logger.info self.inspect
    logger.info user.inspect
    create :user_id=>user.id,:token=>access_token.token,:secret=>access_token.secret
  end
  
end