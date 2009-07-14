require 'twitter'
class TwitterToken < ConsumerToken
  def self.twitter
    @twitter||=Twitter::OAuth.new( OAUTH_CREDENTIALS[:twitter][:key],OAUTH_CREDENTIALS[:twitter][:secret]).consumer
  end
  
  def self.consumer
    @twitter.consumer
  end
  
  def client
    unless @client
      @client=TwitterToken.twitter.clone
      @client.authorize_from_access token,secret
    end
    
    @client
  end
end