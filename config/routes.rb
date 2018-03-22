Rails.application.routes.draw do

  resources :users, :only => [:index, :show]
  resources :downloads, only: [:show]

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
      match 'export' => 'webs#export', via: [:get], as: :export
    end
  end

  # get 'export', to: 'foo#export', as: :foo_export
  # get 'webs/export', to: 'webs#export', as: :export_webs


  resources :acts, :terms, :links
end
