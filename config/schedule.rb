# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
# 'source /home/newhouse/.rvm/scripts/rvm && rvm use 1.9.3 &&
#
env :PATH, ENV['PATH']

# issue/fix for RVM
job_type :rake,    "source /home/newhouse/.rvm/scripts/rvm && rvm use 1.9.3 && cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
job_type :runner, "source /home/newhouse/.rvm/scripts/rvm && rvm use 1.9.3 && cd :path && rails runner -e :environment ':task' :output"
set :output, "/home/newhouse/mechanicalmap/current/log/cron.log"
#
#every 2.minutes do
#   command "/usr/bin/some_great_command"
#   runner "FtSyncAnswers.perform_async"
#  rake "sync"
#end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
