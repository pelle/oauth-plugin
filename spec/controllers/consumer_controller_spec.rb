require 'spec_helper'
require 'dummy_app/app/controllers/application_controller'
require 'dummy_app/app/controllers/oauth_consumers_controller'

describe OauthConsumersController do
  
  describe "callback" do
    context 'when logged in' do
      let(:user   ) { double("user", id: 1234) }
      let(:service) { 'foo'           }
      let(:token  ) { double("token") }
      before(:each) do
        session[:user] = user
        session['my_token'] = 'my_secret'
        ConsumerToken.should_receive(:find).and_return('a_token')
        FooToken.should_receive(:find_or_create_from_request_token).and_return(token)
        get :callback, :id => service, :oauth_token => 'my_token'
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
    end
    context 'when not logged in' do
      let(:user    ) { nil   }
      let(:service ) { 'bar' }
      let(:token   ) { double("token", user: new_user) }
      let(:new_user) { Object.new }
      before(:each) do
        session[:user] = user
        session['my_token'] = 'my_secret'
        BarToken.should_receive(:find_or_create_from_request_token).and_return(token)
        get :callback, :id => service, :oauth_token => 'my_token'
      end
      it 'should set the current user' do
        session[:user].should be(new_user)
      end
      it 'should redirect to root' do
        response.should redirect_to root_url
      end
    end
    context 'when token cannot be retrieved' do
      let(:user    ) { double("user", id: 1234) }
      let(:service ) { 'foo' }
      let(:token   ) { nil   }
      before(:each) do
        session[:user] = user
        session['my_token'] = 'my_secret'
        ConsumerToken.should_receive(:find).and_return('a_token')
        FooToken.should_receive(:find_or_create_from_request_token).and_return(token)
        get :callback, :id => service, :oauth_token => 'my_token'
      end
      it 'should redirect to the service page' do
        response.should redirect_to oauth_consumer_url('foo')
      end
    end
  end
end
