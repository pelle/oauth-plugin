module Oauth
  module Provider
    module Models
      module RequestToken
        extend ActiveSupport::Concern

        include Oauth::Provider::Models::Secret
        include Oauth::Provider::Models::ShortExpiry

        
        included do
          attr_accessor :provided_oauth_verifier
        end

        def authorize!(user)
          return false if authorized?
          self.user = user
          self.authorized_at = Time.now
          self.verifier = SecureRandom.hex
          self.save
        end


        def to_query
          "#{super}&oauth_callback_confirmed=true"
        end

        def oob?
          callback_url.nil? || callback_url.downcase == 'oob'
        end

      end
    end
  end
end  