module Oauth
  module Provider
    module Models
      module Secret
        extend ActiveSupport::Concern
        
        included do
          before_create :generate_secret
        end

        def to_query
          "oauth_token=#{token}&oauth_token_secret=#{secret}"
        end

        protected

          def generate_secret
            self.secret ||= SecureRandom.hex
          end

      end
    end
  end
end  