Rails.application.routes.draw do

  resources :activities
  resources :users, :only => [:index, :show]
  resources :downloads, only: [:show]

  devise_for :users, controllers: { sessions: 'users/sessions' }, path_prefix: 'd', path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }

  get 'home/index'
  root to: 'home#index'

  resources :conts do
    collection do
      match 'search' => 'conts#search', via: [:get, :post], as: :search
      match 'generate_csv' => 'conts#generate_csv', via: [:get, :post], as: :generate_csv
    end
  end

  resources :webs do
    get :flag_data, on: :collection

    collection do
      match 'search' => 'webs#search', via: [:get, :post], as: :search
      match 'generate_csv' => 'webs#generate_csv', via: [:get, :post], as: :generate_csv
    end
  end

  get :toggle_sts, to: 'activities#toggle_sts'

  resources :acts, :terms, :links
end
