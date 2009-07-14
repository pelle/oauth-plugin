require 'agree2'
class Agree2Token < ConsumerToken
  def self.agree2_client
    @agree2_client||=Agree2::Client.new OAUTH_CREDENTIALS[:agree2][:key],OAUTH_CREDENTIALS[:agree2][:secret]
  end
  
  def self.consumer
    agree2_client.consumer
  end
  
  def client
    @client||=Agree2Token.agree2_client.user(:token=>token,:secret=>secret)
  end
end