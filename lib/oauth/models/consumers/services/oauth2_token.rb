require 'oauth2'
class Oauth2Token < ConsumerToken
  after_initialize :ensure_access, if: :expired_and_existing?

  def self.consumer
    @consumer||=create_consumer
  end

  def self.create_consumer(options={})
    @consumer||=OAuth2::Client.new credentials[:key],credentials[:secret],credentials[:options]
  end

  def self.authorize_url(callback_url)
    options = {:redirect_uri=>callback_url}
    options[:scope] = credentials[:scope] if credentials[:scope].present?
    consumer.auth_code.authorize_url(options)
  end

  def self.access_token(user, code, redirect_uri)
    access_token = consumer.auth_code.get_token(code, :redirect_uri => redirect_uri)
    find_or_create_from_access_token user, access_token
  end

  def client
    @client ||= OAuth2::AccessToken.new self.class.consumer, token, {refresh_token: refresh_token, expires_at: expires_at, expires_in: expires_in }
  end

  # @return [Boolean] Is the access token expired and does the record exist in the datastore?
  def expired_and_existing?
    return true if !self.new_record? and Time.now.to_i >= self.expires_at.to_i
    false
  end

  # Refreshes the access token to ensure access
  def ensure_access
    self.class.find_or_create_from_access_token user, self, client.refresh!
  end

  # Returns the expiration date (expires_in, expires_at)
  #
  # @return [String, String] Expires_in and expires_at, respectively
  # @note It will return the default expiration time as defined in the OAuth 2.0 spec when no options are set
  def expiration_date(token)
    return token.expires_in, token.expires_at if !token.expires_in.nil? and !token.expires_at.nil?
    return token.expires_in, (Time.now.to_i + token.expires_in.to_i) if token.expires_at.nil? and !token.expires_in.nil?
    return (token.expires_at.to_i - Time.now.to_i), token.expires_at if token.expires_in.nil? and !token.expires_at.nil?
    return "3600", (Time.now.to_i + 3600)
  end
end