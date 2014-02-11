DummyApp::Application.routes.draw do
  root :to => "home#index"
  
  resources :oauth_consumers, :only => [:show,:destroy] do
    member do
      get :callback
    end
  end
end
