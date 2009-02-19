require 'mongrel_cluster/recipes'

set :application, "example.com"
role :app, application
role :web, application
role :db,  application, :primary => true

set :repository,  "http://osirails.rubyforge.org/svn/trunk/"
set :web_user, "www-data"
set :web_group, "www-data"
set :admin_runner, "admin"  # for try_sudo command
set :user, "admin"          # for ssh connection

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"
#set :mongrel_conf, "#{shared_path}/config/#{application}.yml"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Create shared folders 'assets' and 'config'"
  task :create_shared_folders do
    run "mkdir #{shared_path}/assets"
    run "mkdir #{shared_path}/config"
    run "curl --silent #{repository}config/database.example.yml -o #{shared_path}/config/database.production.yml"
    puts "You may configure '#{shared_path}/config/database.production.yml' before deploy your application."
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.production.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"

    # règle les droits sur le dossier de deploiement
    #sudo "chown #{web_user}:#{web_group} -R #{deploy_to}"
    #sudo "chmod 775 -R #{deploy_to}"
  end
  
#  desc "Sync the assets directory."
#  task :assets do
#    system "rsync -vr --exclude='.DS_Store' assets #{user}@#{application}:#{shared_path}/"
#  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
after 'deploy:setup', 'deploy:create_shared_folders'