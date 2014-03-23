Myflix::Application.routes.draw do
  root 'static_pages#front'

  get 'ui(/:action)', controller: 'ui'

  get 'home', to: 'videos#index'
  get 'register', to: 'users#new'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'

  
  get 'queue', to: 'queue_items#index'
  
  resources :users, only: [:create]
  resources :categories, only: [:show]
  
  resources :videos, only: [:show] do
    resources :reviews, only: [:create]
    collection do 
      get 'search', to: 'videos#search'
    end
  end
end