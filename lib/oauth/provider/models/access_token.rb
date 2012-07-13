module Oauth
  module Provider
    module Models
      module AccessToken
        extend ActiveSupport::Concern

        include Oauth::Provider::Models::Secret
        include Oauth::Provider::Models::Authorized

      end
    end
  end
end  