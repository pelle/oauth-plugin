require 'oauth'
class ClientApplication < ActiveRecord::Base
  belongs_to :user
  has_many :tokens,:class_name=>"OauthToken"
  validates_presence_of :name,:url,:key,:secret
  validates_uniqueness_of :key
  before_validation_on_create :generate_keys
  
  def self.find_for_request(request)
    consumer_key=OAuth::Request.extract_consumer_key(request)
    find_by_key consumer_key if consumer_key
  end
  
  def self.authorize_request?(request)
    oauth_request=OAuth::Request.incoming(request)
    return false unless OauthNonce.remember(oauth_request.nonce,oauth_request.timestamp)
    return false unless oauth_request.token
    token=AccessToken.find_by_token oauth_request.token
    return false unless token
    return false unless token.authorized?
    return false unless oauth_request.verify?(token.client_application.secret,token.secret)
    token
  end
  
  def oauth_server
    @oauth_server||=OAuth::Server.new "http://your.site"
  end
  
  def credentials
    @oauth_client||=OAuth::ConsumerCredentials.new key,secret
  end
    
  def create_request_token(request)
    oauth_request=OAuth::Request.incoming(request)
    return false unless OauthNonce.remember(oauth_request.nonce,oauth_request.timestamp)
    return false if oauth_request.token
    return false unless oauth_request.verify?(secret)
    RequestToken.create :client_application=>self
  end
  
  def exchange_for_access_token(request)
    oauth_request=OAuth::Request.incoming(request)
    return false unless OauthNonce.remember(oauth_request.nonce,oauth_request.timestamp)
    return false unless oauth_request.token
    token=tokens.find_by_token oauth_request.token
    return false unless token
    return false unless token.is_a?(RequestToken)
    return false unless token.authorized?
    return false unless oauth_request.verify?(secret,token.secret)
    token.exchange!
  end

  protected
  
  def generate_keys
    @oauth_client=oauth_server.generate_consumer_credentials
    self.key=@oauth_client.key
    self.secret=@oauth_client.secret
  end
end
