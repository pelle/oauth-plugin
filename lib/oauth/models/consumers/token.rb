require 'oauth/consumer'
require File.join(File.dirname(__FILE__), 'simple_client')

module Oauth
  module Models
    module Consumers
      module Token
        def self.included(model)
          model.class_eval do
            validates_presence_of :user, :token
          end

          model.send(:include, InstanceMethods)
          model.send(:extend, ClassMethods)

        end

        module ClassMethods

          def service_name
            @service_name||=self.to_s.underscore.scan(/^(.*?)(_token)?$/)[0][0].to_sym
          end

          def consumer
            options = credentials[:options] || {}
            @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],options
          end

          def get_request_token(callback_url)
            consumer.get_request_token(:oauth_callback=>callback_url)
          end

          def find_or_create_from_request_token(user,token,secret,oauth_verifier)
            request_token=OAuth::RequestToken.new consumer,token,secret
            options={}
            options[:oauth_verifier]=oauth_verifier if oauth_verifier
            access_token=request_token.get_access_token options
            find_or_create_from_access_token user, access_token
          end

          # Finds, creates or updates a ConsumerToken by finding the token
          # or taking it when it's given. It then updates the attributes and saves the changes/new record to a datastore.
          # @param user [User] The user to which the access token should belong to
          # @param access_token [AccessToken || Oauth2Token] Either a request token taken from the service or a ConsumerToken
          # @param new_token [AccessToken] A new access token, used for refreshing the access token with OAuth 2.
          #
          # Usage example:
          # find_or_create_from_access_token(current_user, access_token) <-- Find or create a new access token
          # find_or_create_from_access-token(current_user, Oauth2Token.last, client.refresh!) <-- Edits existing record with new refreshed information
          def find_or_create_from_access_token(user, access_token, new_token = nil)
            if access_token.class.ancestors.include?(Oauth2Token)
              token = access_token
            else
              if user
                token = self.find_or_initialize_by_user_id_and_token(user.id, access_token.token)
              else
                token = self.find_or_initialize_by_token(access_token.token)
              end
            end

            token = if new_token then set_details(new_token, access_token) else set_details(access_token, token) end

            token.save! if token.new_record? or token.changed?

            token
          end

          # Set the details such as the secret, refresh token and expiration time to an instance of ConsumerToken
          # @return [ConsumerToken] A ConsumerToken
          def set_details(access_token, token)
            secret = access_token.respond_to?(:secret) ? access_token.secret : nil
            refresh_token = access_token.respond_to?(:refresh_token) ? access_token.refresh_token : nil
            expires_in, expires_at = token.expiration_date(access_token) if token.class.ancestors.include?(Oauth2Token)

            token.token = access_token.token
            token.refresh_token = refresh_token
            token.secret = secret
            token.expires_at = expires_at
            token.expires_in = expires_in

            token
          end

          def build_user_from_token
          end
          
          def credentials
            @credentials||=OAUTH_CREDENTIALS[service_name]
          end

        end

        module InstanceMethods

          # Main client for interfacing with remote service. Override this to use
          # preexisting library eg. Twitter gem.
          def client
            @client||=OAuth::AccessToken.new self.class.consumer,token,secret
          end

          def simple_client
            @simple_client||=SimpleClient.new client
          end

          # Override this to return user data from service
          def params_for_user
            {}
          end

          def create_user
            self.user ||= begin
              User.new params_for_user
              user.save(:validate=>false)
            end
          end

        end
      end
    end
  end
end
