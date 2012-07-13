module Oauth
  module Provider
    module Models
      module Authorizable
        extend ActiveSupport::Concern

        def invalidated?
          invalidated_at != nil
        end

        def invalidate!
          update_attribute(:invalidated_at, Time.now)
        end

        def authorized?
          authorized_at != nil && !invalidated?
        end

        def expires_in
          expires_at.to_i - Time.now.to_i if expires_at
        end

      end
    end
  end
end  