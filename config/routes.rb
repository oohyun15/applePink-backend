Rails.application.routes.draw do

  root "posts#index"

  post "auth_user" => "authentication#authenticate_user"
  get "apis/test"

  get 'users/sign_in', to: 'authentication#new'
  post 'users/sign_in', to: 'authentication#create'
  get 'users/sign_up', to: 'users#new'
  post 'users/sign_up', to: 'users#create'

  resources :users, only: %i(index show edit update destroy)
 
  resources :posts
  resources :chats
end
