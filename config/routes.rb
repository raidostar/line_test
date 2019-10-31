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
    resources :friends
  end

  namespace :api, format: 'json' do
    resources :follows
  end

  namespace :api, format: 'json' do
    resources :groups, only: [:index,:create]
  end

  namespace :api, format: 'json' do
    resources :notifies
  end

  namespace :api, format: 'json' do
    resources :emojis, only: [:index,:create]
  end

  namespace :api, format: 'json' do
    resources :tags
  end

  namespace :api, format: 'json' do
    resources :options
  end

  namespace :api, format: 'json' do
    resources :reactions
  end

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
  post '/create_notify' => 'api/showmes#create_notify'
  # get '/emojis' =>'api/showmes#index_emoji'
  get 'api/cancel_reaction' => 'api/reactions#cancel_reaction'
  get '*path', controller: 'application', action: 'render_404'
  post 'api/reactions_all' => 'api/reactions#index_all_except'
  post 'api/link_option_reaction' => 'api/reactions#link_option_reaction'
  post 'api/reactions_by_tag' => 'api/reactions#index_by_tag'
  post 'api/options_by_tag' => 'api/options#index_by_tag'
  post 'api/direct_reply' => 'api/showmes#direct_reply'
  post 'api/by_fr_account' => 'api/friends#find_by_fr_account'
  post 'api/get_last_message' => 'api/messages#get_last_message'
  post 'api/keyword_check' => 'api/options#keyword_check'
  post 'api/read_message' => 'api/messages#read_message'
  post 'api/check_message' => 'api/messages#check_message'
  post 'api/fetch_follows_data' => 'api/follows#fetch_follows_data'
  post 'api/fetch_follows_time_data' => 'api/follows#fetch_follows_time_data'
  post 'api/fetch_messages_data' => 'api/messages#fetch_messages_data'
  post 'api/fetch_messages_time_data' => 'api/messages#fetch_messages_time_data'
  post 'api/fetch_message_type_data' => 'api/messages#fetch_message_type_data'
  post 'api/fetch_message_check_data' => 'api/messages#fetch_message_check_data'
  post 'api/fetch_targets' => 'api/friends#fetch_targets'
  post 'api/fetch_welcome_reactions' => 'api/reactions#index_welcome_reaction'
  post 'api/update_option_bool' => 'api/options#update_option_bool'
  post 'api/update_option_remind' => 'api/options#update_option_remind'
  post 'api/notify_again' => 'api/showmes#notify_again'
end
