class RequestToken < OauthToken
  include Oauth::Provider::Models::RequestToken
  
  def exchange!
    return false unless authorized?
    return false unless verifier==provided_oauth_verifier

    RequestToken.transaction do
      access_token = AccessToken.create(:user => user, :client_application => client_application)
      invalidate!
      access_token
    end
  end

end
