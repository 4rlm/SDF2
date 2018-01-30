Rails.application.routes.draw do
  resources :acts
  get 'home/index'
  root :to => "home#index"

  resources :acts, :conts

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
