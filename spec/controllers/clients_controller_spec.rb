require 'spec_helper'
require 'dummy_app/app/controllers/application_controller'
require 'dummy_app/app/controllers/oauth_clients_controller'

describe OauthClientsController do
  
  describe "create" do
    let(:operation) { 'created' }
    def request
      get :create
    end
    before(:each) do
      session[:user]      = user
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
  
  describe "update" do
    let(:operation) { 'updated' }
    def request
      put :update, id: client_application_id
    end
    before(:each) do
      session[:user]      = user
      session['my_token'] = 'my_secret'
    end
    context 'when logged in' do
      let(:client_applications)   { double("client_applications") }
      let(:user       )           { double("user", id: 1234, client_applications: client_applications) }
      let(:client_application_id) { 4321 }
      before(:each) do
        allow(client_applications).to receive(:find).with(client_application_id.to_s) { client_application }
      end
      context 'with a known client application' do
        before(:each) do
          expect(client_application).to receive(:update_attributes).with(nil) { update_result }
          request
        end
        context 'with valid client application attributes' do
          let(:client_application ) { double("client_application", id: client_application_id) }
          let(:update_result)       { true }
          it 'should redirect to oauth_clients_url' do
            response.should redirect_to action: "show", id: client_application_id
          end
          it 'should set the application updated flash message' do
            expect(flash[:notice]).to eq "Updated the client information successfully"
          end
        end
        context 'with invalid client application attributes' do
          let(:client_application ) { double("client_application", id: client_application_id) }
          let(:update_result)       { false }
          it 'should render the edit view' do
            response.should render_template :edit
          end
        end
      end
      context 'with an unkown client application' do
        let(:client_application ) { nil   }
        let(:update_result)       { false }
        it 'raises a NotFound error' do
          expect { request }.to raise_error ActiveRecord::RecordNotFound
        end
        it 'sets the not found flash error message' do
          begin
            request
          rescue
          end
          expect(flash[:error]).to eq "Wrong application id"
        end
      end
    end
  end
  
end
