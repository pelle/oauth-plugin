require 'active_model/validations'
require 'active_model/conversion'
require 'active_model/naming'
require 'active_model/callbacks'

# Dummy implementation
class ClientApplication
  attr_accessor :key

  def self.find_by_key(key)
    ClientApplication.new(key)
  end

  def initialize(key)
    @key = key
  end

  def tokens
    @tokens||=[]
  end

  def secret
    "secret"
  end
end

class OauthToken
  # extend ActiveModel::Naming
  # include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  define_model_callbacks :create
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  include Oauth::Provider::Models::Token
  include Oauth::Provider::Models::Authorizable

  attr_accessor :secret, :token, :token_digest, :expires_at, :invalidated_at, :authorized_at

  def self.first(conditions_hash)
    case conditions_hash[:conditions].last
    when "not_authorized", "invalidated"
      nil
    else
      OauthToken.new(conditions_hash[:conditions].last)
    end
  end

  def initialize(token = nil)
    self.token = token
    @secret = 'secret'
  end

  def save
    if valid? 
      _run_create_callbacks do
        self
      end
    end
    self
  end

end

class Oauth2Token < OauthToken 
  include Oauth::Provider::Models::BearerToken
end

class Oauth2Verifier < OauthToken
  include Oauth::Provider::Models::Verifier

end
class AccessToken < OauthToken 
  include Oauth::Provider::Models::AccessToken
end

class RequestToken < OauthToken
  attr_accessor :user, :verifier
  include Oauth::Provider::Models::RequestToken
end

class OauthNonce
  # Always remember
  def self.remember(nonce,timestamp)
    true
  end
end
