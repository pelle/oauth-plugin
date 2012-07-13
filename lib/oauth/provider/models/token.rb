module Oauth
  module Provider
    module Models
      module Token
        extend ActiveSupport::Concern

        included do
          before_create :generate_token
          attr_accessor :token
        end

        protected

          def generate_token
            self.token ||= SecureRandom.hex
            self.token_digest ||= Digest::SHA1.hexdigest(token)
          end

      end
    end
  end
end  