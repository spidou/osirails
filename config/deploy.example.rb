require 'capistrano/ext/multistage'

default_run_options[:pty]   = true # it would seem we don't get the passphrase prompt from git if we don't
ssh_options[:forward_agent] = true # If you're using your own private keys for git you might want to tell Capistrano to use agent forwarding with this command

set :stages, %w(production demo staging)
set :default_stage, "staging"

set :application,     "osirails"
set :domain,          "my-server"
set :repository,      "git@github.com:spidou/osirails.git"
set :use_sudo,        false
set :deploy_to,       "/path/to/#{application}"
set :user,            "user"

set :scm,             "git"
set :branch,          "master"
set :deploy_via,      :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end


set :web_user,  "www-data"
set :web_group, "www-data"

task :after_update_code, :roles => :app do
  # create the database.yml file
  db_prod = "#{shared_path}/config/database.production.yml"
  run "cp #{db_prod} #{release_path}/config/database.yml"
  
  # create symlinks for assets
  run "ln -sf #{shared_path}/assets #{release_path}/assets"

  # setup rights for 'www-data' on the 'deploy_to' folder
  sudo "chown #{web_user}:#{web_group} -R #{deploy_to}"
end
