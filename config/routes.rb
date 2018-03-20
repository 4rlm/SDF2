Rails.application.routes.draw do

  # devise_for :users
  # devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}

  # devise_for :users, controllers: { sessions: 'users/sessions' }
  # devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }

  devise_for :users, controllers: { sessions: 'users/sessions' }, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }


  # get 'signup', to: 'users#new', as: 'signup'
  # get 'login', to: 'sessions#new', as: 'login'
  # get 'logout', to: 'sessions#destroy', as: 'logout'

  get 'home/index'
  root to: 'home#index'

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

  # resources :acts, :conts, :profiles, :sessions, :users, :webs
  resources :acts, :conts, :terms, :links, :webs
end
