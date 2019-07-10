Rails.application.routes.draw do
  root 'home#index'

  resources :books

  namespace :api, format: 'json' do
    resources :books, only: [:index, :create, :update, :show, :destroy]
  end

  post 'linebot/callback'
end
