class TwitterToken < ConsumerToken
  TWITTER_SETTINGS={
    :site => "https://api.twitter.com",
    :request_token_path => "/oauth/request_token",
    :authorize_path => "/oauth/authorize",
    :access_token_path => "/oauth/access_token",
  }
  
  def self.consumer(options={})
    @consumer ||= OAuth::Consumer.new(credentials[:key], credentials[:secret], TWITTER_SETTINGS.merge(options))
  end
end
