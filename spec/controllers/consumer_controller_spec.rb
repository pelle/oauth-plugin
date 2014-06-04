require 'spec_helper'
require 'dummy_app/app/controllers/application_controller'
require 'dummy_app/app/controllers/oauth_consumers_controller'

describe OauthConsumersController do
  let(:token_class) { double("token_class", service_name: service)}
  
  describe "callback" do
    before(:each) do
      session[:user] = user
      session['my_token'] = 'my_secret'
      I18n.should_receive(:t).with("#{service}.#{operation}", {:scope => 'oauth_plugin.oauth_consumers', :default => [operation.to_sym], :service => service.humanize}).and_call_original
    end
    context 'when logged in' do
      let(:user       ) { double("user", id: 1234) }
      let(:service    ) { 'foo'           }
      let(:token      ) { double("token", class: token_class) }
      let(:operation  ) { 'connected' }
      before(:each) do
        ConsumerToken.should_receive(:find).and_return('a_token')
        FooToken.should_receive(:find_or_create_from_request_token).and_return(token)
        get :callback, :id => service, :oauth_token => 'my_token'
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
      it 'should set the successfully connected flash message' do
        expect(flash[:notice]).to eq "#{service.humanize} was successfully connected to your account"
      end
    end
    context 'when not logged in' do
      let(:user       ) { nil   }
      let(:service    ) { 'bar' }
      let(:token      ) { double("token", class: token_class, user: new_user) }
      let(:new_user   ) { Object.new }
      let(:operation  ) { 'logged_in' }
      before(:each) do
        BarToken.should_receive(:find_or_create_from_request_token).and_return(token)
        get :callback, :id => service, :oauth_token => 'my_token'
      end
      it 'should set the current user' do
        session[:user].should be(new_user)
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
      it 'should set the logged in using service flash message' do
        expect(flash[:notice]).to eq "You logged in with #{service.humanize}"
      end
    end
    context 'when token cannot be retrieved' do
      let(:user     ) { double("user", id: 1234) }
      let(:service  ) { '' }
      let(:token    ) { nil   }
      let(:operation) { 'error' }
      before(:each) do
        ConsumerToken.should_receive(:find).and_return('a_token')
        FooToken.should_receive(:find_or_create_from_request_token).and_return(token)
        get :callback, :id => 'foo', :oauth_token => 'my_token'
      end
      it 'should redirect to the service page' do
        response.should redirect_to oauth_consumer_url('foo')
      end
      it 'should set an error flash message' do
        expect(flash[:error]).to eq "An error happened, please try connecting again"
      end
    end
  end
  
  describe "callback2" do
    before(:each) do
      session[:user] = user
      session['my_token'] = 'my_secret'
      I18n.should_receive(:t).with("#{service}.#{operation}", {:scope => 'oauth_plugin.oauth_consumers', :default => [operation.to_sym], :service => service.humanize}).and_call_original
    end
    context 'when logged in' do
      let(:user     ) { double("user", id: 1234) }
      let(:service  ) { 'foo'           }
      let(:token    ) { double("token", class: token_class) }
      let(:operation) { 'connected' }
      before(:each) do
        ConsumerToken.should_receive(:find).and_return('a_token')
        FooToken.should_receive(:access_token).and_return(token)
        get :callback2, :id => service, :oauth_token => 'my_token'
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
      it 'should set the successfully connected flash message' do
        expect(flash[:notice]).to eq "#{service.humanize} was successfully connected to your account"
      end
    end
    context 'when not logged in' do
      let(:user     ) { nil   }
      let(:service  ) { 'bar' }
      let(:token    ) { double("token", class: token_class, user: new_user) }
      let(:new_user ) { Object.new }
      let(:operation) { 'logged_in' }
      before(:each) do
        BarToken.should_receive(:access_token).and_return(token)
        get :callback2, :id => service, :oauth_token => 'my_token'
      end
      it 'should set the current user' do
        session[:user].should be(new_user)
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
      it 'should set the logged in using service flash message' do
        expect(flash[:notice]).to eq "You logged in with #{service.humanize}"
      end
    end
    context 'when token cannot be retrieved' do
      let(:user     ) { double("user", id: 1234) }
      let(:service  ) { '' }
      let(:token    ) { nil   }
      let(:operation) { 'error' }
      before(:each) do
        ConsumerToken.should_receive(:find).and_return('a_token')
        FooToken.should_receive(:access_token).and_return(token)
        get :callback2, :id => 'foo', :oauth_token => 'my_token'
      end
      it 'should redirect to the service page' do
        response.should redirect_to oauth_consumer_url('foo')
      end
      it 'should set an error flash message' do
        expect(flash[:error]).to eq "An error happened, please try connecting again"
      end
    end
  end
  
  describe "destroy" do
    before(:each) do
      session[:user] = user
    end
    context "when not reconnecting" do
      let(:user   ) { double("user", id: 1234) }
      let(:service) { 'foo'           }
      let(:token  ) do
        token = double("token", class: token_class)
        expect(token).to receive(:destroy)
        token
      end
      let(:operation) { 'disconnected' }
      before(:each) do
        session[:user] = user
        ConsumerToken.should_receive(:find).and_return(token)
        I18n.should_receive(:t).with("#{service}.#{operation}", {:scope => 'oauth_plugin.oauth_consumers', :default => [operation.to_sym], :service => service.humanize}).and_call_original
        get :destroy, :id => service
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
      it 'should set the successfully disconnected flash message' do
        expect(flash[:notice]).to eq "#{service.humanize} was successfully disconnected from your account"
      end
    end
    context "when reconnecting" do
      let(:user   ) { double("user", id: 1234) }
      let(:service) { 'foo'           }
      let(:token  ) do
        token = double("token")
        expect(token).to receive(:destroy)
        token
      end
      before(:each) do
        session[:user] = user
        ConsumerToken.should_receive(:find).and_return(token)
        get :destroy, :id => service, :commit => 'Reconnect'
      end
      it 'should redirect to root' do
        response.should redirect_to oauth_consumer_url('foo')
      end
    end
  end
end
