Rails.application.routes.draw do
  devise_for :users, contorllers: {
    sessions: 'users/sessions'
  }
  root 'home#index'

  namespace :api, format: 'json' do
    resources :books, only: [:index, :create, :update, :show, :destroy]
  end

  resources :books

  namespace :api, format: 'json' do
    resources :people, only: [:index]
  end

  resources :people

end
