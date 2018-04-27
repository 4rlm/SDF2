Rails.application.routes.draw do

  resources :users, :only => [:index, :show]
  resources :downloads, only: [:show]
  # resources :activities, only: [:toggle_sts]

  devise_for :users, controllers: { sessions: 'users/sessions' }, path_prefix: 'd', path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }

  get 'home/index'
  root to: 'home#index'

  resources :acts do
    collection do
      match 'search' => 'acts#search', via: [:get, :post], as: :search
      match 'generate_csv' => 'acts#generate_csv', via: [:get, :post], as: :generate_csv

      match 'followed' => 'acts#followed', via: [:get, :post], as: :followed
      match 'hidden' => 'acts#hidden', via: [:get, :post], as: :hidden
    end
  end

  resources :conts do
    collection do
      match 'search' => 'conts#search', via: [:get, :post], as: :search
      match 'generate_csv' => 'conts#generate_csv', via: [:get, :post], as: :generate_csv

      match 'followed' => 'conts#followed', via: [:get, :post], as: :followed
      match 'hidden' => 'conts#hidden', via: [:get, :post], as: :hidden

      match 'show_web' => 'conts#show_web', via: [:get, :post], as: :show_web
    end
  end

  resources :webs do
    get :flag_data, on: :collection

    collection do
      match 'search' => 'webs#search', via: [:get, :post], as: :search
      match 'generate_csv' => 'webs#generate_csv', via: [:get, :post], as: :generate_csv
      match 'followed' => 'webs#followed', via: [:get, :post], as: :followed
      match 'hidden' => 'webs#hidden', via: [:get, :post], as: :hidden
      match 'followed_acts' => 'webs#followed_acts', via: [:get, :post], as: :followed_acts
      match 'hidden_acts' => 'webs#hidden_acts', via: [:get, :post], as: :hidden_acts

      match 'show_conts' => 'webs#show_conts', via: [:get, :post], as: :show_conts
    end
  end

  resources :act_activities do
    collection do
      match 'follow_all' => 'act_activities#follow_all', via: [:get, :post], as: :follow_all
      match 'unfollow_all' => 'act_activities#unfollow_all', via: [:get, :post], as: :unfollow_all
      match 'hide_all' => 'act_activities#hide_all', via: [:get, :post], as: :hide_all
      match 'unhide_all' => 'act_activities#unhide_all', via: [:get, :post], as: :unhide_all
    end
  end

  resources :cont_activities do
    collection do
      match 'follow_all' => 'cont_activities#follow_all', via: [:get, :post], as: :follow_all
      match 'unfollow_all' => 'cont_activities#unfollow_all', via: [:get, :post], as: :unfollow_all
      match 'hide_all' => 'cont_activities#hide_all', via: [:get, :post], as: :hide_all
      match 'unhide_all' => 'cont_activities#unhide_all', via: [:get, :post], as: :unhide_all
    end
  end

  resources :web_activities do
    collection do
      match 'follow_all' => 'web_activities#follow_all', via: [:get, :post], as: :follow_all
      match 'unfollow_all' => 'web_activities#unfollow_all', via: [:get, :post], as: :unfollow_all
      match 'hide_all' => 'web_activities#hide_all', via: [:get, :post], as: :hide_all
      match 'unhide_all' => 'web_activities#unhide_all', via: [:get, :post], as: :unhide_all
    end
  end

  resources :queries do
    collection do
      match 'follow_all' => 'queries#follow_all', via: [:get, :post], as: :follow_all
      match 'unfollow_all' => 'queries#unfollow_all', via: [:get, :post], as: :unfollow_all
      match 'hide_all' => 'queries#hide_all', via: [:get, :post], as: :hide_all
      match 'unhide_all' => 'queries#unhide_all', via: [:get, :post], as: :unhide_all
    end
  end

  resources :tallies, only: [:index] do
    collection do
      match 'follow_all' => 'tallies#follow_all', via: [:get, :post], as: :follow_all
      match 'unfollow_all' => 'tallies#unfollow_all', via: [:get, :post], as: :unfollow_all
      match 'hide_all' => 'tallies#hide_all', via: [:get, :post], as: :hide_all
      match 'unhide_all' => 'tallies#unhide_all', via: [:get, :post], as: :unhide_all
      match 'generate_csv' => 'tallies#generate_csv', via: [:get, :post], as: :generate_csv
      match 'refresh_process' => 'tallies#refresh_process', via: [:get, :post], as: :refresh_process
    end
  end

  # resources :photos, only: [:new, :create, :index, :destroy]
  resources :photos, only: [:new, :create, :index, :destroy] do
    collection do
      match 'perform' => 'photos#perform', via: [:get, :post], as: :perform
      match 'download_csv' => 'photos#download_csv', via: [:get, :post], as: :download_csv
    end
  end


  get 'admin/index'
  get 'admin/change_user_level' => 'admin#change_user_level'
  get 'admin/delete_user' => 'admin#delete_user'

  resources :terms, :links
end
