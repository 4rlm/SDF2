Rails.application.routes.draw do

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

  get 'home/index'
  root :to => "home#index"
  resources :acts, :conts, :webs, :adrs, :phones
end
