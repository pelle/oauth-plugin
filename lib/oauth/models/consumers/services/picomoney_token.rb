require File.join(File.dirname(__FILE__),'opentransact_token')

class PicomoneyToken < OpenTransactToken

  def self.credentials
    @credentials||={
        :site=>"https://picomoney.com",
        :consumer_key => super.delete(:key),
        :consumer_secret => super.delete(:secret)
      }.merge(super)
  end  
  
  def about_user
    client.get("/about_user")
  end

end