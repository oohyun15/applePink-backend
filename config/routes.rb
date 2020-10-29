Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  #ActiveAdmin 관련 오류로 수정함
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  root "authentication#new"

  get 'users/sign_in', to: 'authentication#new'
  post 'users/sign_in', to: 'authentication#create'
  post 'users/sign_up', to: 'users#create'
  post 'users/like', to: 'likes#toggle'
  
  # put 'bookings/:id', to: 'bookings#complete'
  
  resources :users, only: %i(index show edit update) do
    resources :likes, only: %i(index)
    collection do
      get :list
      get :mypage
      post :email_auth
      delete :withdrawal
    end
  end
  resources :posts
  resources :chats do
    resources :messages, only: %i(index create)  
  end
  resources :image, only: %i(create destroy)
  resources :locations, only: %i(index show) do
    put :certificate, on: :collection
  end
  resources :bookings, only: %i(index show create destroy) do
    put :complete, on: :collection
  end
end
