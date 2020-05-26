require File.expand_path(File.dirname(__FILE__) + "/environment")
require "tzinfo"

rails_env = ENV['RAILS_ENV'] || :development

set :environment, rails_env
set :output, "#{Rails.root}/log/cron.log"

every :day, at: '11:34 am' do  #1.minutes do
  rake 'daily:remind_reply'
end
