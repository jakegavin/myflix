Myflix::Application.routes.draw do

  resources :videos, only: [:show] do
    resources :reviews, only: [:create]
    collection do 
      get 'search', to: 'videos#search'
    end
  end  
  get 'home', to: 'videos#index'

  resources :categories, only: [:show]

  resources :users, only: [:create, :show]
  get '/register(/:token)', to: 'users#new', as: 'register'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'

  resources :invites, only: [:create]
  get 'invite', to: 'invites#new'

  resources :forgot_passwords, only: [:create]
  get 'forgot_password', to: 'forgot_passwords#new'
  get 'password_reset_confirmation', to: 'forgot_passwords#password_reset_confirmation'
  resources :reset_passwords, only: [:show, :create]
  get 'invalid_token', to: 'reset_passwords#invalid_token'
  
  resources :queue_items, only: [:destroy]
  post 'modify_queue', to: 'queue_items#modify'
  get 'queue', to: 'queue_items#index'
  post 'queue', to: 'queue_items#create'

  resources :relationships, only: [:create, :destroy]
  get 'following', to: 'relationships#index'

  root 'static_pages#front'

  get 'ui(/:action)', controller: 'ui'
end