module Oauth
  module Provider
    module Models
      module ShortExpiry
        extend ActiveSupport::Concern
        
        included do
          before_create :set_expiry
        end

        protected

          def set_expiry
            self.expires_at = Time.now() + 600
          end

      end
    end
  end
end  