require 'spec_helper'
require 'dummy_app/app/controllers/application_controller'
require 'dummy_app/app/controllers/oauth_controller'

describe OauthController do
  
  describe "revoke" do
    before(:each) do
      session[:user] = user
      session['my_token'] = 'my_secret'
    end
    context 'when logged in' do
      let(:user_tokens) { double("user_tokens")                                                 }
      let(:user       ) { double("user", id: 1234, tokens: user_tokens)                         }
      let(:token      ) { double("token", client_application: double("app", name: "fancy-app")) }
      before(:each) do
        expect(token).to receive(:invalidate!)
        allow(user_tokens).to receive(:"find_by_token!").with('my_token') { token }
        get :revoke, :token => 'my_token'
      end
      it 'should redirect to oauth_clients_url' do
        response.should redirect_to oauth_clients_url
      end
      it 'should set the token revoked flash message' do
        expect(flash[:notice]).to eq "You've revoked the token for #{token.client_application.name}"
      end
    end
  end
  
end
