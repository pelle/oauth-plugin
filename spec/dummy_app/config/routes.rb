DummyApp::Application.routes.draw do
  root :to => "home#index"
  
  resources :oauth_consumers, :only => [:show,:destroy] do
    member do
      get :callback
      get :callback2
    end
  end
end
