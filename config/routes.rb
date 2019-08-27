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

  namespace :api, format: 'json' do
    resources :groups, only: [:index,:create]
  end

  post '/find_message' => 'api/messages#show_with_id'
  post '/find_messages' => 'api/messages#index_with_id'
  post '/show_current' => 'api/users#show_current_user'

  post '/number_of_monthly' => 'api/messages#get_number_of_monthly_message'
  post '/number_of_weekly' => 'api/messages#get_number_of_weekly_message'
  post '/number_of_daily' => 'api/messages#get_number_of_daily_message'
  post '/number_of_seven_days' => 'api/messages#get_number_of_seven_days'
  post '/find_group_key' => 'api/groups#show_with_group_key'
  # post '/add_number' => 'api/friends#number_of_add_by_date'
  # post '/block_number' => 'api/friends#number_of_block_by_date'
  # post '/week_date' => 'api/friends#get_date_info'
  post '/weekly_friend_info' => 'api/friends#get_weekly_friend_info'


end
