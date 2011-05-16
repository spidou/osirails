source 'http://rubygems.org'

gem 'rails', '2.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql'

# Use mongrel as the web server
gem 'mongrel', '1.1.5' # if you got an error like this : "dependencies.rb:142:in `load_without_new_constant_marking': no such file to load -- mongrel_rails (MissingSourceFile)"
                       # go to /path/to/mongrel_gem/lib (using "bundle show mongrel" to see where it is installed)
                       # and run "ln -s ../bin/mongrel_rails mongrel_rails"
                       # it should be OK after that!
#gem 'mongrel_cluster', '1.0.5'

# Bundle the extra gems:
gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'json', '1.4.6'
gem 'RedCloth', '4.2.3'
gem 'htmlentities', '4.2.1'
gem 'whenever', :git => 'git://github.com/spidou/whenever.git'
gem 'orderedhash' # it can be deleted once we use ruby1.9

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'ruby-debug'
  
  # To run test:benchmark
  gem 'ruby-prof'
end

group :test do
  gem 'shoulda', '2.10.2'
end

group :deploy do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext' # for multistage
end
