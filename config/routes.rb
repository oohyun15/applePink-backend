Rails.application.routes.draw do

  root "posts#index"

  post "auth_user" => "authentication#authenticate_user"
  get "apis/test"

  get 'users/sign_in', to: 'users#log_in'
  post 'users/sign_in', to: 'users#sign_in'
  get 'users/sign_up', to: 'users#new'
  post 'users/sign_up', to: 'users#create'

  resources :users, only: %i(index show edit update destroy)
 
  resources :posts
  resources :chats
end
