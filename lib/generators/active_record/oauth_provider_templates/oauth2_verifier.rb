class Oauth2Verifier < OauthToken
  include Oauth::Provider::Models::Verifier
    
  validates_presence_of :user

  def exchange!(params={})
    ActiveRecor.transaction do
      token = Oauth2Token.create! :user=>user,:client_application=>client_application, :scope => scope
      invalidate!
      token
    end
  end


  
end
