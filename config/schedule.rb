require File.expand_path(File.dirname(__FILE__) + "/environment")

rails_env = ENV['RAILS_ENV'] || :development

set :environment, rails_env
set :output, "#{Rails.root}/log/cron.log"

every :day, at: ('05:30 pm') do # 1.minute do
  # rake 'follows_update:follow_block_update', :environment => "development"
  runner
end
