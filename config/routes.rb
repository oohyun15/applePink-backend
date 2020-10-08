Rails.application.routes.draw do

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root "authentication#new"

  get 'users/sign_in', to: 'authentication#new'
  post 'users/sign_in', to: 'authentication#create'
  post 'users/sign_up', to: 'users#create'
  
  resources :users, only: %i(index show edit update destroy) do
    collection do
      get :kakao
    end
  end
  resources :posts
  resources :chats

end
