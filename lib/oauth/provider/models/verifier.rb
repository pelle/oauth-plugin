module Oauth
  module Provider
    module Models
      module Verifier
        extend ActiveSupport::Concern
        include Oauth::Provider::Models::Authorized
        include Oauth::Provider::Models::ShortExpiry

        
        def code
          token
        end

        def redirect_url
          callback_url
        end

        def to_query
          q = "code=#{token}"
          q << "&state=#{URI.escape(state)}" if state
          q
        end

      end
    end
  end
end  