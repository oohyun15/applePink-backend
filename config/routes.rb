Rails.application.routes.draw do
  get 'api/test'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root "posts#index"

  post 'auth_user' => 'authentication#authenticate_user'
  get 'apis/test'

  resources :users
  resources :posts
  resources :chats
end
