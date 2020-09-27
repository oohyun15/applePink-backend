Rails.application.routes.draw do

  root "authentication#new"

  get 'users/sign_in', to: 'authentication#new'
  post 'users/sign_in', to: 'authentication#create'
  get 'users/sign_up', to: 'users#new'
  post 'users/sign_up', to: 'users#create'
  
  resources :users, only: %i(index show edit update destroy)
  resources :posts
  resources :chats

end
