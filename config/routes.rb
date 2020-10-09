Rails.application.routes.draw do

  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root "authentication#new"

  get 'users/sign_in', to: 'authentication#new'
  post 'users/sign_in', to: 'authentication#create'
  post 'users/sign_up', to: 'users#create'
  
  get '/users/auth/:provider/callback', to: 'sessions#create'

  resources :users, only: %i(index show edit update destroy)
  resources :posts
  resources :chats

  resources :image, only: %i(create destroy)

end
