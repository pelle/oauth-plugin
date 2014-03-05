DummyApp::Application.routes.draw do
  resources :oauth_clients
  get   '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request
  get   '/oauth/token',         :to => 'oauth#token',         :as => :token
  get   '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token
  get   '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
  match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize,    :via => [:get, :post]
  get   '/oauth',               :to => 'oauth#index',         :as => :oauth
  root :to => "home#index"
  
  resources :oauth_consumers, :only => [:show,:destroy] do
    member do
      get :callback
      get :callback2
    end
  end
end
