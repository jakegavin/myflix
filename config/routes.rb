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
  get 'register', to: 'users#new'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'
  get 'forgot_password', to: 'users#forgot_password'
  post 'forgot_password', to: 'users#generate_token'
  get 'password_reset_confirmation', to: 'static_pages#password_reset_confirmation'
  get 'reset_password/(:password_reset_token)', to: 'users#reset_password', as: :reset_password
  post 'reset_password', to: 'users#reset_password'
  get 'invalid_token', to: 'static_pages#invalid_token'

  resources :queue_items, only: [:destroy]
  post 'modify_queue', to: 'queue_items#modify'
  get 'queue', to: 'queue_items#index'
  post 'queue', to: 'queue_items#create'

  resources :relationships, only: [:create, :destroy]
  get 'following', to: 'relationships#index'

  root 'static_pages#front'

  get 'ui(/:action)', controller: 'ui'
end