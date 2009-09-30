class GoogleToken < ConsumerToken
  GOOGLE_SETTINGS={
    :site=>"https://www.google.com", 
    :request_token_path => "/accounts/OAuthGetRequestToken",
    :authorize_path => "/accounts/OAuthAuthorizeToken",
    :access_token_path => "/accounts/OAuthGetAccessToken",
  }
  
  def self.consumer
    @consumer||=create_consumer
  end 
  
  def self.create_consumer(options={})
    OAuth::Consumer.new credentials[:key],credentials[:secret],GOOGLE_SETTINGS.merge(options)
  end
  
  def self.portable_contacts_consumer
    @portable_contacts_consumer||= create_consumer :site=>"http://www-opensocial.googleusercontent.com"
  end
  
  
  def self.get_request_token(callback_url, scope=nil)
    consumer.get_request_token({:oauth_callback=>callback_url}, :scope=>scope||credentials[:scope]||"http://www-opensocial.googleusercontent.com/api/people")
  end
  
  def portable_contacts
    @portable_contacts||= GooglePortableContacts.new(OAuth::AccessToken.new( self.class.portable_contacts_consumer, token, secret))
  end
  
  class GooglePortableContacts < Oauth::Models::Consumers::SimpleClient
    
    def me
      get("/api/people/@me/@self")
    end

    def all
      get("/api/people/@me/@all")
    end

  end
end