class OauthToken < ActiveRecord::Base
  include Oauth::Provider::Models::Token
  include Oauth::Provider::Models::Authorizable

  belongs_to :client_application
  belongs_to :user
  validates_presence_of :client_application

  scope :valid, where(["invalidated_at IS NULL AND authorized_at IS NOT NULL AND (expires_at is null or expires_at >= ?)", Time.now])
  scope :by_token, lambda { |token| valid.where(:token_digest => Digest::SHA1.hexdigest(token))}
  
  def self.find_by_valid_token(token)
    valid.by_token(token).first
  end
end
