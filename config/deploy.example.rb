require 'mongrel_cluster/recipes'

set :application, "example"
set :repository,  "http://svn.example.com/svn/trunk/"
set :web_user, "www-data"
set :web_group, "www-data"
set :admin_runner, "admin" # for try_sudo command
set :user, "admin" # for ssh connection

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "example.com"
role :web, "example.com"
role :db,  "example.com", :primary => true

task :after_update_code, :roles => :app do
  # crée le fichier database.yml
  db_prod = "#{shared_path}/config/database.production.yml"
  run "cp #{db_prod} #{release_path}/config/database.yml"

  # règle les droits sur le dossier de deploiement
  sudo "chown #{web_user}:#{web_group} -R #{deploy_to}"
  sudo "chmod 775 -R #{deploy_to}"
end
