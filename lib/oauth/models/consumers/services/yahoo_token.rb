class YahooToken < ConsumerToken
  YAHOO_SETTINGS={
    :site=>"https://www.yahoo.com", 
    :request_token_url => "https://api.login.yahoo.com/oauth/v2/get_request_token",
    :authorize_url => "https://api.login.yahoo.com/oauth/v2/request_auth",
    :access_token_url => "https://api.login.yahoo.com/oauth/v2/get_token"
  }
  
  def self.consumer
    @consumer||=create_consumer
  end
  
  def self.create_consumer(options={})
    OAuth::Consumer.new credentials[:key],credentials[:secret],YAHOO_SETTINGS.merge(options)
  end
  
  def self.social_apis_consumer
    @social_api_consumer||=create_consumer :site=>"http://social.yahooapis.com/v1"
  end
  
  def self.get_request_token(callback_url, scope=nil)
    YahooRequestToken.new consumer.get_request_token({:oauth_callback=>callback_url}, :scope=>scope||credentials[:scope])
  end
  
  # We need to do some special handling to handle this strange parameter:
  # 
  class YahooRequestToken < OAuth::RequestToken
    def initialize(real_token)
      super real_token.consumer,real_token.token,real_token.secret
      @params=real_token.params
    end
    
    # handle xoauth_request_auth_url
    def authorize_url(params = nil)
      if @params[:xoauth_request_auth_url]
        return @params[:xoauth_request_auth_url]
      else
        super params
      end
    end
  end
  
  def social_api
    @social_api ||= SocialAPI.new(OAuth::AccessToken.new( self.class.social_apis_consumer, token, secret))
  end
  
  class SocialAPI
    attr_reader :token
    
    # initial implementation of this
    # http://developer.yahoo.com/social/rest_api_guide/index.html
    # Please fork and submit improvements here
    def initialize(token)
      @token = token
    end
    
    def guid
      @guid||=get("/v1/me/guid")["guid"]["value"]
    end
    
    def usercard
      get("/v1/user/#{guid}/profile/usercard")
    end
    
    def idcard
      get("/v1/user/#{guid}/profile/idcard")
    end
    
    def tinyusercard
      get("/v1/user/#{guid}/profile/tinyusercard")
    end
    
    def profile
      get("/v1/user/#{guid}/profile")
    end
    
    def contacts
      get("/v1/user/#{guid}/contacts")
    end
    
    def put(path,params={})
      parse(token.put(path,params, {'Accept' => 'application/json'}))
    end

    def delete(path)
      parse(token.delete(path, {'Accept' => 'application/json'}))
    end

    def post(path,params={})
      parse(token.post(path,params, {'Accept' => 'application/json'}))
    end

    def get(path)
      parse(token.get(path, {'Accept' => 'application/json'}))
    end

    protected

    def parse(response)
      return false unless response
      if ["200","201"].include? response.code
        unless response.body.blank?
          JSON.parse(response.body)
        else
          true
        end
      else
        logger.debug "Got Response code: #{response.code}"
        false
      end
    end

  end
end


# I have reported this as a bug to Yahoo, but on certain occassions their tokens are returned with spaces that confuse CGI.parse.
# The only change below is that it strips the response.body. Once Yahoo fixes this I will remove this whole section.
module OAuth
  class Consumer
    
    def token_request(http_method, path, token = nil, request_options = {}, *arguments)
      response = request(http_method, path, token, request_options, *arguments)

      case response.code.to_i

      when (200..299)
        # symbolize keys
        # TODO this could be considered unexpected behavior; symbols or not?
        # TODO this also drops subsequent values from multi-valued keys
        
        CGI.parse(response.body.strip).inject({}) do |h,(k,v)|
          h[k.to_sym] = v.first
          h[k]        = v.first
          h
        end
      when (300..399)
        # this is a redirect
        response.error!
      when (400..499)
        raise OAuth::Unauthorized, response
      else
        response.error!
      end
    end
  end
end