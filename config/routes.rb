RailsStarter::Application.routes.draw do
  get ':controller(/:action(/:id))'
  root :to => 'say#hello'

  post '/callback' => 'linebot#callback'

  namespace :api do
    resources :visitors, only: [:index, :create]
  end 
end
