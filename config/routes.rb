Rails.application.routes.draw do

  resources :users, :only => [:index, :show]
  resources :downloads, only: [:show]
  # resources :activities, only: [:toggle_sts]

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

  # resources :activities do
  #   collection do
  #     match 'toggle_fav' => 'activities#toggle_fav', via: [:get, :post], as: :toggle_fav
  #     match 'toggle_hide' => 'activities#toggle_hide', via: [:get, :post], as: :toggle_hide
  #     match 'toggle_sts' => 'activities#toggle_sts', via: [:get, :post], as: :toggle_sts
  #   end
  # end
  # get :toggle_sts, to: 'activities#toggle_sts'

  resources :acts, :terms, :links, :activities
end
