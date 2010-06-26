require 'oauth/signature'
module OAuth
  module Controllers
   
    module ApplicationControllerMethods
      
      def self.included(controller)
        controller.class_eval do  
          extend ClassMethods
        end
      end
      
      module ClassMethods
        def oauthenticate(options={})
          filter_options = {}
          filter_options[:only]   = options.delete(:only) if options[:only]
          filter_options[:except] = options.delete(:except) if options[:except]
          before_filter Filter.new(options), filter_options
        end
      end
      
      class Filter
        def initialize(options={})
          @options={
              :interactive=>true,
              :strategies => [:token,:two_legged]
            }.merge(options)
          @strategies = Array(@options[:strategies])
          @strategies << :interactive if @options[:interactive]
        end
        
        def filter(controller)
          Authenticator.new(controller,@strategies).allow?
        end
      end
      
      class Authenticator
        attr_accessor :controller, :strategies, :strategy
        def initialize(controller,strategies)
          @controller = controller
          @strategies = strategies
        end
        
        def params
          controller.send :params
        end
        def request
          controller.send :request
        end
        
        def allow?
          if @strategies.any? do |strategy| 
              @strategy  = strategy.to_sym
              send @strategy
            end
            true
          else
            controller.send :invalid_oauth_response
            false
          end
        end

        def oauth20_token
          return false unless defined?(Oauth2Token)
          token, options = token_and_options
          token ||= params[:oauth_token] || params[:access_token]
          if !token.blank?
            @oauth2_token = Oauth2Token.find_by_token(token)
            if @oauth2_token && @oauth2_token.authorized?
              controller.send :current_token=, @oauth2_token
            end
          end
          @oauth2_token!=nil
        end

        def oauth10_token
          begin
            if ClientApplication.verify_request(request) do |request_proxy|
                @oauth_token = ClientApplication.find_token(request_proxy.token)
                if @oauth_token.respond_to?(:provided_oauth_verifier=)
                  @oauth_token.provided_oauth_verifier=request_proxy.oauth_verifier 
                end
                # return the token secret and the consumer secret
                [(@oauth_token.nil? ? nil : @oauth_token.secret), (@oauth_token.client_application.nil? ? nil : @oauth_token.client_application.secret)]
              end
              controller.send :current_token=, @oauth_token
              true
            else
              false
            end
          rescue
            false
          end
        end

        def oauth10_request_token
          oauth10_token && @oauth_token.is_a?(::RequestToken)
        end

        def oauth10_access_token
          oauth10_token && @oauth_token.is_a?(::AccessToken)
        end
        
        def token
          oauth20_token || oauth10_access_token
        end
        
        def two_legged
          begin
            if ClientApplication.verify_request(request) do |request_proxy|
                @client_application = ClientApplication.find_by_key(request_proxy.consumer_key)

                # Store this temporarily in client_application object for use in request token generation 
                @client_application.token_callback_url=request_proxy.oauth_callback if request_proxy.oauth_callback

                # return the token secret and the consumer secret
                [nil, @client_application.secret]
              end
              controller.send :current_client_application=, @client_application
              true
            else
              false
            end
          rescue
            false
          end
        end
        
        def interactive
          @controller.send :logged_in?
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
              
      protected
      
      def current_token
        @current_token
      end
      
      def current_client_application
        @current_client_application
      end
      
      def oauth?
        current_token!=nil
      end
      
      # use in a before_filter. Note this is for compatibility purposes. Better to use oauthenticate now
      def oauth_required
        Authenticator.new(self,[:oauth10_access_token]).allow?
      end
      
      # use in before_filter. Note this is for compatibility purposes. Better to use oauthenticate now
      def login_or_oauth_required
        Authenticator.new(self,[:oauth10_access_token,:interactive]).allow?
      end
      
      def invalid_oauth_response(code=401,message="Invalid OAuth Request")
        render :text => message, :status => code
        false
      end

      private
      
      def current_token=(token)
        @current_token=token
        if @current_token
          @current_user=@current_token.user
          @current_client_application=@current_token.client_application
        else
          @current_user = nil
          @current_client_application = nil
        end
        @current_token
      end
      
      def current_client_application=(app)
        if app
          @current_client_application = app
          @current_user = app.user
        else
          @current_client_application = nil
          @current_user = nil
        end
      end
    end
  end
end