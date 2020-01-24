Rails.application.routes.draw do
  get 'groups/index'
  get 'groups/create'
  get 'groups/show'
  get '/health' => 'api/healths#health'
  devise_for :users, contorllers: {
    sessions: 'users/sessions'
  }

  root 'home#index'

  namespace :api, format: 'json' do
    resources :users, only: [:show]
  end

  namespace :api, format: 'json' do
    resources :messages, only: [:index, :create, :show]
  end

  resources :messages

  post '/callback/fullout' => 'api/messages#callback'
  post '/callback' => 'api/lines#callback'

  namespace :api, format: 'json' do
    resources :friends
  end

  namespace :api, format: 'json' do
    resources :bubbles
  end

  namespace :api, format: 'json' do
    resources :bubbles_archives
  end

  namespace :api, format: 'json' do
    resources :follows
  end

  namespace :api, format: 'json' do
    resources :groups
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

  namespace :api, format: 'json' do
    resources :richactions
  end

  namespace :api, format: 'json' do
    resources :richmenus
  end

  namespace :api, format: 'json' do
    resources :postbacks
  end

  namespace :api, format: 'json' do
    resources :channels
  end

  post '/find_messages' => 'api/messages#index_with_id'
  post 'api/show_current' => 'api/users#show_current_user'
  post 'api/timely_messages' => 'api/messages#timely_messages'
  post 'users/api/find_group_key' => 'api/groups#find_group_key'
  post 'api/weekly_friend_info' => 'api/friends#get_weekly_friend_info'

  post 'users/api/idCheck' => 'api/users#id_check'
  post 'api/create_notify' => 'api/lines#create_notify'
  get 'api/cancel_reaction' => 'api/reactions#cancel_reaction'
  get '*path', controller: 'application', action: 'render_404'
  post 'api/reactions_all' => 'api/reactions#index_all_except'
  post 'api/link_option_reaction' => 'api/reactions#link_option_reaction'
  post 'api/reactions_by_tag' => 'api/reactions#index_by_tag'
  post 'api/options_by_tag' => 'api/options#index_by_tag'
  post 'api/direct_reply' => 'api/lines#direct_reply'
  post 'api/by_fr_account' => 'api/friends#find_by_fr_account'
  post 'api/get_last_message' => 'api/messages#get_last_message'
  post 'api/keyword_check' => 'api/options#keyword_check'
  post 'api/read_message' => 'api/messages#read_message'
  post 'api/check_message' => 'api/messages#check_message'
  post 'api/fetch_follows_data' => 'api/follows#fetch_follows_data'
  post 'api/fetch_follows_time_data' => 'api/follows#fetch_follows_time_data'
  post 'api/fetch_messages_data' => 'api/messages#fetch_messages_data'
  post 'api/fetch_messages_time_data' => 'api/messages#fetch_messages_time_data'
  post 'api/fetch_personal_message_data' => 'api/messages#fetch_personal_message_data'
  post 'api/fetch_message_type_data' => 'api/messages#fetch_message_type_data'
  post 'api/fetch_message_check_data' => 'api/messages#fetch_message_check_data'
  post 'api/fetch_targets' => 'api/friends#fetch_targets'
  post 'api/fetch_welcome_reactions' => 'api/reactions#index_welcome_reaction'
  post 'api/update_option_bool' => 'api/options#update_option_bool'
  post 'api/update_option_remind' => 'api/options#update_option_remind'
  post 'api/notify_again' => 'api/lines#notify_again'
  post 'api/fetch_bubbles' => 'api/bubbles#fetch_bubbles'
  post 'api/fetch_bubbles_archives' => 'api/bubbles_archives#fetch_bubbles_archives'
  post 'api/fetch_reply' => 'api/messages#fetch_reply'
  post 'api/update_bubbles' => 'api/bubbles#update_bubbles'
  post 'api/set_richmenu' => 'api/lines#set_richmenu'
  post 'api/set_default_richmenu' => 'api/lines#set_default_richmenu'
  post 'api/unset_default_richmenu' => 'api/lines#unset_default_richmenu'
  post 'api/delete_richmenu' => 'api/lines#delete_richmenu'
  post 'api/load_all_richmenus' => 'api/lines#load_all_richmenus'
  post 'api/make_group_key' => 'api/groups#make_group_key'
  post 'api/fetch_channels' => 'api/channels#fetch_channels'
  post 'api/save_target_channel' => 'api/users#save_target_channel'
  post 'api/update_follows' => 'api/lines#update_follows'
  post 'api/fetch_groups' => 'api/groups#fetch_groups'
  post 'api/check_channel_limit' => 'api/groups#check_channel_limit'
  post 'api/fetch_members' => 'api/users#fetch_members'
  post 'api/users_update' => 'api/users#users_update'
  post 'api/fetch_current_channel' => 'api/channels#fetch_current_channel'
end
