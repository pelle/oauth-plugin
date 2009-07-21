gem 'paulsingh-twitter' # go back to regular twitter gem when it is bumped to oauth 0.3.5
require 'twitter'
class TwitterToken < ConsumerToken
  TWITTER_SETTINGS={:site=>"http://twitter.com"}
  def self.consumer
    @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],TWITTER_SETTINGS
  end
  
  def client
    unless @client
      @twitter_oauth=Twitter::OAuth.new TwitterToken.consumer.key,TwitterToken.consumer.secret
      @twitter_oauth.authorize_from_access token,secret
      @client=Twitter::Base.new(@twitter_oauth)
    end
    
    @client
  end
end