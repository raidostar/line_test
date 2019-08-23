require File.expand_path(File.dirname(__FILE__) + "/environment")

rails_env = ENV['RAILS_ENV'] || :development

set :environment, rails_env
set :output, "#{Rails.root}/log/cron.log"

every :day, at: ('00:05 am') do
  rake 'follows_update:follow_block_update', :environment => "development"
end
