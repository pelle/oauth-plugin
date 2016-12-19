class RequestToken < OauthToken
  attr_accessor :provided_oauth_verifier

  def authorize!(user)
    return false if authorized?
    self.user           = user
    self.authorized_at  = Time.now
    self.verifier       = SecureRandom.hex
    self.save
  end

  def exchange!
    return false unless authorized?
    return false unless verifier == provided_oauth_verifier

    AccessToken.create(:user => user, :client_application => client_application).tap do
      invalidate!
    end
  end

  def to_query
    "#{super}&oauth_callback_confirmed=true"
  end

  def oob?
    callback_url.nil? || callback_url.downcase == 'oob'
  end

end
