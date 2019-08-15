Rails.application.routes.draw do
  get 'groups/index'
  get 'groups/create'
  get 'groups/show'
  devise_for :users, contorllers: {
    sessions: 'users/sessions'
  }
  root 'home#index'

  namespace :api, format: 'json' do
    resources :users, only: [:show]
  end

  namespace :api, format: 'json' do
    resources :books, only: [:index, :create, :update, :show, :destroy]
  end

  resources :books

  namespace :api, format: 'json' do
    resources :people, only: [:index]
  end

  resources :people

  namespace :api, format: 'json' do
    resources :messages, only: [:index, :create, :show]
  end

  resources :messages

  post '/callback/fullout' => 'api/messages#callback'
  post '/callback' => 'api/showmes#callback'

  namespace :api, format: 'json' do
    resources :friends, only: [:index, :show]
  end

  resources :friends

  post '/find_message' => 'api/messages#show_with_id'
  post '/find_messages' => 'api/messages#index_with_id'
  post '/show_current' => 'api/users#show_current_user'
end
