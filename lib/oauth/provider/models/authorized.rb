module Oauth
  module Provider
    module Models
      module Authorized
        extend ActiveSupport::Concern
        
        included do
          before_create :set_authorized_at
        end

        protected

          def set_authorized_at
            self.authorized_at = Time.now
          end

      end
    end
  end
end  