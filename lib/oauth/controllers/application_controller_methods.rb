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
          controller.send :oauth_authenticator=, self
        end
        
        def allow?
          if !(@strategies & env["oauth.strategies"].to_a).empty?
            true
          else
            if @strategies.include?(:interactive) 
              controller.send :access_denied
            else
              controller.send :invalid_oauth_response
            end
          end
        end

        def oauth20_token
           env["oauth.version"]==2 && env["oauth.token"]
        end

        def oauth10_token
          env["oauth.version"]==1 && env["oauth.token"]
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

        def client_application
          env["oauth.version"]==1 && env["oauth.client_application"] || oauth20_token.try(:client_application)
        end

        def two_legged
           env["oauth.version"]==1 && client_application
        end
        
        def interactive
          @controller.send :logged_in?
        end

        def env
          request.env
        end

        def request
          controller.send :request
        end

      end
              
      protected
      
      def current_token
        @oauth_authenticator.try(:token)
      end
      
      def current_client_application
        @oauth_authenticator.try(:client_application)
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
      
      # override this in your controller
      def access_denied
        head 401
      end

      private
      
      def oauth_authenticator=(auth)
        @oauth_authenticator = auth
      end
    end
  end
end