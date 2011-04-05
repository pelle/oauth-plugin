require 'twitter'
class TwitterToken < ConsumerToken
  TWITTER_SETTINGS={:site=>"http://twitter.com"}
  def self.consumer
    @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],TWITTER_SETTINGS
  end
  
  def client
    @client ||= Twitter::Client.new(:consumer_key => TwitterToken.consumer.key, :consumer_secret => TwitterToken.consumer.secret)
  end
end
