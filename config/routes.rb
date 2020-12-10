Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  devise_for :admin_users, ActiveAdmin::Devise.config
  #ActiveAdmin 관련 오류로 수정함
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad
  # match '*path', to: 'application#route_not_found', via: :all
  root "home#index"
  post 'users/sign_in', to: 'authentication#create'
  post 'users/sign_up', to: 'users#create'
  post 'users/like', to: 'likes#toggle'
  post "/kakaocert/requestESign", to: 'kakaocert#requestESign'
  get "/kakaocert/getESignState", to: 'kakaocert#getESignState'
  get "/kakaocert/verifyESign", to: 'kakaocert#verifyESign'

  # put 'bookings/:id', to: 'bookings#complete'
  
  resources :users, only: %i(index show update) do
    resources :likes, only: %i(index)
    collection do
      get :mypage
      get :keyword
      post :keyword
      post :email_auth
      post :sms_auth
      post :add_device
      post :remove_device
      post :find
      delete :withdrawal
      delete :keyword
      put :reset
      put :range
    end
    member do
      get :list
    end
  end
  
  resources :posts do
    member do
      get :like
    end
  end
  
  resources :chats do
    resources :messages, only: %i(index create)  
    collection do
      get :count
    end
  end
  
  resources :image, only: %i(create destroy)
  
  resources :locations, only: %i(index show) do
    put :certificate, on: :collection
    get :display, on: :collection
  end
  resources :bookings, only: %i(index new show create destroy) do
    put :complete, on: :member
    put :accept, on: :member
  end

  resources :companies, only: %i(show create destroy) do
    patch :confirm, on: :member
  end

  resources :reports, only: %i(index create)
  resources :questions, only: %i(create)
  resources :reviews, only: %i(index create update destroy)
  resources :pages, only: %i(show)
end
