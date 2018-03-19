Rails.application.routes.draw do

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  get 'home/index'
  root :to => "home#index"

  resources :conts do
    collection do
      match 'search' => 'conts#search', via: [:get, :post], as: :search
    end
  end

  resources :webs do
    collection do
      match 'search' => 'webs#search', via: [:get, :post], as: :search
    end
  end

  resources :acts, :conts, :profiles, :sessions, :users, :webs
end
