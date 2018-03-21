Rails.application.routes.draw do

  resources :users, :only => [:index, :show]

  devise_for :users, controllers: { sessions: 'users/sessions' }, path_prefix: 'd', path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }

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

  resources :acts, :terms, :links
end
