module OAuth
  module Rails
   
    module ControllerMethods
      protected
      
      def current_token
        @current_token
      end
      
      def oauthenticate
        token=ClientApplication.authorize_request?(request)
        return false unless token
        @current_token=token
        @current_user=@current_token.user
        @current_token
      end
      
      def oauth?
        current_token!=nil
      end
      
      # use in a before_filter
      def oauth_required
        if oauthenticate&&authorized?
          true
        else
          access_denied
        end
      end
      
      # This requies that you have an acts_as_authenticated compatible authentication plugin installed
      def login_or_oauth_required
        if oauthenticate
          if authorized?
            return true
          else
            access_denied
          end
        else
          login_required
        end
      end
    end
  end
end