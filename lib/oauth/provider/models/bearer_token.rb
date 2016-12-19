module Oauth
  module Provider
    module Models
      module BearerToken
        extend ActiveSupport::Concern

        include Oauth::Provider::Models::Authorized

        def as_json(options={})
          d = {:access_token=>token, :token_type => 'bearer'}
          d[:expires_in] = expires_in if expires_at
          d
        end

        def to_query
          q = "access_token=#{token}&token_type=bearer"
          q << "&state=#{URI.escape(state)}" if state
          q << "&expires_in=#{expires_in}" if expires_at
          q << "&scope=#{URI.escape(scope)}" if scope
          q
        end

      end
    end
  end
end  