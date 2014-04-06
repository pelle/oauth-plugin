require 'spec_helper'
require 'dummy_app/app/controllers/application_controller'
require 'dummy_app/app/controllers/oauth_clients_controller'

describe OauthClientsController do
  
  describe "create" do
    let(:operation) { 'created' }
    before(:each) do
      session[:user] = user
      session['my_token'] = 'my_secret'
    end
    context 'when logged in' do
      let(:client_applications) { double("client_applications") }
      let(:user       )         { double("user", id: 1234, client_applications: client_applications) }
      before(:each) do
        expect(client_application).to receive(:save)  { save_result        }
        allow(client_applications).to receive(:build) { client_application }
        get :create
      end
      context 'with a valid client application' do
        let(:client_application ) { double("client_application", id: 4321) }
        let(:save_result)         { true }
        it 'should redirect to oauth_clients_url' do
          response.should redirect_to action: "show", id: 4321
        end
        it 'should set the application created flash message' do
          expect(flash[:notice]).to eq "Registered the information successfully"
        end
      end
      context 'with an invalid client application' do
        let(:client_application ) { double("client_application") }
        let(:save_result)         { false }
        it 'should render the new view' do
          response.should render_template :new
        end
      end
    end
  end
  
end
