Rails.application.routes.draw do
  resources :webs
  get 'home/index'
  root :to => "home#index"

  resources :acts, :conts, :webs

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
