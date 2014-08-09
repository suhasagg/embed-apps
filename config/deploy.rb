

Dir['lib/**/*.rb'].each { |recipe| require  File.basename(recipe, '.rb') }


load 'deploy/assets'
require "rvm/capistrano"
set :rvm_type, :user
set :rvm_ruby_string, :local

require 'sidekiq/capistrano'

# bundler bootstrap
require 'bundler/capistrano'

set :user, 'newhouse'
set :domain, 'mechanicaltask.dev.fabelier.org'
set :application, "mechanicalmap"
set :applicationdir, "/home/newhouse/mechanicalmap"
set :repository, "git://github.com/nmaisonneuve/mechanicalmap.git"  # Your clone URL
set :scm, "git"
set :scm_verbose, true
set :git_enable_submodules, 1

# roles (servers)
role :web, domain
role :app, domain
role :db, domain, :primary=>true

# deploy config
set :deploy_to, applicationdir
set :deploy_via, :remote_cache
set :use_sudo, false

set :bundle_cmd, 'source $HOME/.bash_profile && bundle'

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
ssh_options[:forward_agent] = true

set :whenever_command, "source $HOME/.bash_profile && bundle exec whenever"
require "whenever/capistrano"

desc "Fix permission"
task :fix_permissions, :roles => [ :app, :db, :web ] do
  run "#{try_sudo} chmod 777 -R #{current_path}/script"
end

desc "sidekiq"
task :activate_sidekiq_workers do
  run "cd #{release_path} && bundle exec sidekiq start -e production"
end

after "deploy:create_symlink", :fix_permissions

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do

# cap deploy deploy:db_schema_load
  desc "Load the initial schema - it will WIPE your database, use with care"
  task :db_schema_load, :roles => :db, :only => { :primary => true } do
    puts <<-EOF

************************** WARNING ***************************
If you type [yes], rake db:schema:load will WIPE your database
any other input will cancel the operation.
**************************************************************

EOF
    answer = Capistrano::CLI.ui.ask "Are you sure you want to WIPE your database?: "
    if answer == 'yes'
      run "cd #{current_path} && RAILS_ENV=production bundle exec rake db:create"
      run "cd #{current_path} && RAILS_ENV=production bundle exec rake db:schema:load"
    else
      puts "Cancelled."
    end
  end

   task :start do ; end
   task :stop do ; end

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end