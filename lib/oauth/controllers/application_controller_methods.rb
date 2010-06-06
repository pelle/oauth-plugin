require 'oauth/signature'
module OAuth
  module Controllers
   
    module ApplicationControllerMethods
      protected
      
      def current_token
        @current_token
      end
      
      def current_client_application
        @current_client_application
      end
      
      def oauthenticate
        verified=verify_oauth_signature 
        return verified && current_token.is_a?(::AccessToken)
      end
      
      def oauth?
        current_token!=nil
      end
      
      # use in a before_filter
      def oauth_required
        if oauthenticate
          if authorized?
            return true
          else
            invalid_oauth_response
          end
        else          
          invalid_oauth_response
        end
      end
      
      # This requies that you have an acts_as_authenticated compatible authentication plugin installed
      def login_or_oauth_required
        if oauthenticate
          if authorized?
            return true
          else
            invalid_oauth_response
          end
        else
          login_required
        end
      end
      
      
      # verifies a request token request
      def verify_oauth_consumer_signature
        begin
          valid = ClientApplication.verify_request(request) do |request_proxy|
            @current_client_application = ClientApplication.find_by_key(request_proxy.consumer_key)
            
            # Store this temporarily in client_application object for use in request token generation 
            @current_client_application.token_callback_url=request_proxy.oauth_callback if request_proxy.oauth_callback
            
            # return the token secret and the consumer secret
            [nil, @current_client_application.secret]
          end
        rescue
          valid=false
        end

        invalid_oauth_response unless valid
      end

      def verify_oauth_request_token
        verify_oauth_signature && current_token.is_a?(::RequestToken)
      end

      def invalid_oauth_response(code=401,message="Invalid OAuth Request")
        render :text => message, :status => code
      end

      private
      
      def current_token=(token)
        @current_token=token
        if @current_token
          @current_user=@current_token.user
          @current_client_application=@current_token.client_application 
        end
        @current_token
      end
      
      # Implement this for your own application using app-specific models
      def verify_oauth_signature
        verify_oauth20 || verify_oauth10
      end
      
      def verify_oauth20
        return false unless defined?(Oauth2Token)
        token, options = token_and_options
        token ||= params[:oauth_token] || params[:access_token]
        if !token.blank?
          oauth2_token = Oauth2Token.find_by_token(token)
          if oauth2_token && oauth2_token.authorized?
            self.current_token=oauth2_token
          end
        end
        self.current_token!=nil
      end
      
      def verify_oauth10
        begin
          valid = ClientApplication.verify_request(request) do |request_proxy|
            self.current_token = ClientApplication.find_token(request_proxy.token)
            if self.current_token.respond_to?(:provided_oauth_verifier=)
              self.current_token.provided_oauth_verifier=request_proxy.oauth_verifier 
            end
            # return the token secret and the consumer secret
            [(current_token.nil? ? nil : current_token.secret), (current_client_application.nil? ? nil : current_client_application.secret)]
          end
          # reset @current_user to clear state for restful_...._authentication
          @current_user = nil if (!valid)
          valid
        rescue
          false
        end
      end
      
      # Blatantly stolen from http://github.com/technoweenie/http_token_authentication
      # Parses the token and options out of the token authorization header.  If
      # the header looks like this:
      #   Authorization: Token token="abc", nonce="def"
      # Then the returned token is "abc", and the options is {:nonce => "def"}
      #
      # request - ActionController::Request instance with the current headers.
      #
      # Returns an Array of [String, Hash] if a token is present.
      # Returns nil if no token is found.
      def token_and_options
        if header = ActionController::HttpAuthentication::Basic.authorization(request).to_s[/^Token (.*)/]
          values = $1.split(',').
            inject({}) do |memo, value|
              value.strip!                      # remove any spaces between commas and values
              key, value = value.split(/\=\"?/) # split key=value pairs
              value.chomp!('"')                 # chomp trailing " in value
              value.gsub!(/\\\"/, '"')          # unescape remaining quotes
              memo.update(key => value)
            end
          [values.delete("token"), values.with_indifferent_access]
        end
      end
      
    end
  end
end